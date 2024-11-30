import List "mo:base/List";
import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";

actor TodoList {

  public type TodoId = Nat32;  // Unique identifier for each To-Do item

  public type Todo = {
    description : Text;  // Description of the To-Do item
    done : Bool;         // Status of the To-Do item (completed or not)
  };

  private stable var next : TodoId = 0;  // Track the next available TodoId
  private stable var todos : Trie.Trie<TodoId, Todo> = Trie.empty();  // Store To-Do items in a Trie

  // Function to create a new To-Do item
  public func create(todo : Todo) : async TodoId {
    let todoId = next;  // Get the current TodoId
    next += 1;  // Increment the next ID for the next To-Do
    todos := Trie.replace(
      todos,
      key(todoId),
      Nat32.equal,
      ?todo,  // Store the new To-Do item in the Trie
    ).0;
    return todoId;  // Return the ID of the newly created To-Do
  };

  // Function to read a To-Do item by its ID
  public query func read(todoId : TodoId) : async ?Todo {
    let result = Trie.find(todos, key(todoId), Nat32.equal);
    return result;  // Return the To-Do item if found, or null if not found
  };

  // Function to update a To-Do item by its ID
  public func update(todoId : TodoId, todo : Todo) : async Bool {
    let result = Trie.find(todos, key(todoId), Nat32.equal);
    let exists = Option.isSome(result);  // Check if the To-Do item exists
    if (exists) {
      todos := Trie.replace(
        todos,
        key(todoId),
        Nat32.equal,
        ?todo,  // Update the To-Do item in the Trie
      ).0;
    };
    return exists;  // Return true if the To-Do item was updated, false if it didn't exist
  };

  // Function to delete a To-Do item by its ID
  public func delete(todoId : TodoId) : async Bool {
    let result = Trie.find(todos, key(todoId), Nat32.equal);
    let exists = Option.isSome(result);  // Check if the To-Do item exists
    if (exists) {
      todos := Trie.replace(
        todos,
        key(todoId),
        Nat32.equal,
        null,  // Remove the To-Do item from the Trie
      ).0;
    };
    return exists;  // Return true if the To-Do item was deleted, false if it didn't exist
  };

  // Helper function to generate a key for a TodoId
  private func key(x : TodoId) : Trie.Key<TodoId> {
    return { hash = x; key = x };  // Create a key based on the TodoId
  };
};
