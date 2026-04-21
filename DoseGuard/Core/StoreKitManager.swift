import StoreKit
import Combine

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    private var transactionListener: Task<Void, Error>?
    
    enum ProductID {
        static let monthly = "com.zzoutuo.DoseGuard.pro.monthly"
        static let yearly = "com.zzoutuo.DoseGuard.pro.yearly"
        static let lifetime = "com.zzoutuo.DoseGuard.pro.lifetime"
        
        static let all: Set<String> = [monthly, yearly, lifetime]
    }
    
    enum PolicyURL {
        static let privacyPolicy = URL(string: "https://asunnyboy861.github.io/DoseGuard-pravicy/")!
        static let termsOfUse = URL(string: "https://asunnyboy861.github.io/DoseGuard-terms/")!
    }
    
    nonisolated private init() {
        Task { @MainActor in
            self.transactionListener = self.listenForTransactions()
            await self.loadProducts()
            await self.updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: ProductID.all)
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func purchase(_ product: Product) async throws {
        isPurchasing = true
        defer { isPurchasing = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
    
    var isProUnlocked: Bool {
        purchasedProductIDs.contains(ProductID.monthly) ||
        purchasedProductIDs.contains(ProductID.yearly) ||
        purchasedProductIDs.contains(ProductID.lifetime)
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task { @MainActor in
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    self.purchasedProductIDs.insert(transaction.productID)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}