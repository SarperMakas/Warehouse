import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";

actor Warehouse {

  public type ProductId = Nat32;
  public type Time = Int;

  public type Product = {
    name: Text;
    category: Text;
    weight: Float;
    dimensions: {
      width: Float;
      height: Float;
      depth: Float;
    };
    arrivalTime: Time;
    estimatedDepartureTime: Time;
    actualDepartureTime: ?Time;
    storageCost: Float;
  };

  private stable var next: ProductId = 0;
  private stable var products: Trie.Trie<ProductId, Product> = Trie.empty();

  public func create(product: Product) : async ProductId {
    let productId = next;
    next += 1;
    products := Trie.replace(products, key(productId), Nat32.equal, ?product).0;
    return productId;
  };

  public query func read(productId: ProductId) : async ?Product {
    let result = Trie.find(products, key(productId), Nat32.equal);
    return result;
  };

  public func update(productId: ProductId, product: Product) : async Bool {
    let result = Trie.find(products, key(productId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      products := Trie.replace(products, key(productId), Nat32.equal, ?product).0;
    };
    return exists;
  };

  public func delete(productId: ProductId) : async Bool {
    let result = Trie.find(products, key(productId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {
      products := Trie.replace(products, key(productId), Nat32.equal, null).0;
    };
    return exists;
  };

  public query func readAll() : async [Product] {
    let iter = Trie.iter(products);

    var values: [Product] = [];
    for ((_, v) in iter) {
      values := Array.append(values, [v]);
    };

    return values;
  };

  private func key(x: ProductId): Trie.Key<ProductId> {
    return {
      hash = x;
      key = x;
    };
  };
}
