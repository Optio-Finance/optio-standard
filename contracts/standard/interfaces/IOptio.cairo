%lang starknet

from contracts.utils.structs import Transaction, ClassMetadata, UnitMetadata, Values

// @title Interface for managing tokenized rights and obligations

@contract_interface
namespace IOptio {
    // @notice Allows transferring units in batches or individually
    // @param sender The address of the tokens holder
    // @param recipient The address of the tokens recipient
    // @param transactions_len The counter used for recursion
    // @param transactions The set of transactions to be processed
    func transferFrom(
        sender: felt, recipient: felt, transactions_len: felt, transactions: Transaction*
    ) {
    }

    // @notice Allows to transfer allowances in batches or individually
    // @param sender The address of the tokens holder
    // @param recipient The address of the tokens recipient
    // @param transactions_len The counter used for recursion
    // @param transactions The set of transactions to be processed
    func transferAllowanceFrom(
        sender: felt, recipient: felt, transactions_len: felt, transactions: Transaction*
    ) {
    }

    // @notice Allows issuing rights and obligations to an address
    // @dev Restricted to the authorized issuers of a contract
    // @param recipient The address of the tokens recipient
    // @param transactions_len The counter used for recursion
    // @param transactions The set of transactions to be processed
    func issue(recipient: felt, transactions_len: felt, transactions: Transaction*) {
    }

    // @notice Allows redeeming rights and obligations from an address
    // @dev Restricted to the authorized issuers of a contract
    // @param recipient The address of the tokens recipient
    // @param transactions_len The counter used for recursion
    // @param transactions The set of transactions to be processed
    func redeem(sender: felt, transactions_len: felt, transactions: Transaction*) {
    }

    // @notice Allows burning tokens at the end of the token lifecycle
    // @param sender The address of the tokens holder
    // @param transactions_len The counter used for recursion
    // @param transactions The set of transactions to be processed
    func burn(sender: felt, transactions_len: felt, transactions: Transaction*) {
    }

    // @notice Allows `spender` to withdraw tokens from `owner` up to the approved limit
    // @param owner The address of tokens owner
    // @param spender The address of tokens spender
    // @param transactions_len The counter used for recursion
    // @param transactions The set of transactions to be processed
    func approve(owner: felt, spender: felt, transactions_len: felt, transactions: Transaction*) {
    }

    // @notice Allows to set or revoke `operator` approval to manage a caller's tokens
    // @param operator The address of operator
    // @param approved Either the address is allowed to manage tokens or not
    func setApprovalFor(operator: felt, approved: felt) {
    }

    // @notice Returns the approval status of the `operator` for a certain `owner`
    // @param owner The address which is approving `spender` to operate over all tokens in all `owner` Units
    // @param operator The address which is going to be approved for operating over tokens
    // @returns the allowance amount
    func isApprovedFor(owner: felt, operator: felt) -> (approved: felt) {
    }

    // @notice Returns the latest unit in the class
    // @param class_id The class id to search within
    // @returns the unit id if found
    func getLatestUnit(class_id: felt) -> (unit_id: felt) {
    }

    // @notice Creates the metadata for a given class
    // @param class_id The exact class id to create a metadata for
    // @param metadata_id The id to store metadata in
    // @param metadata The metadata to store
    func createClassMetadata(class_id: felt, metadata_id: felt, metadata: ClassMetadata) {
    }

    // @notice Creates the metadata for a given class
    // @param class_ids_len The length of class ids array
    // @param class_ids The class ids to navigate
    // @param metadata_ids_len The length of metadata ids array
    // @param metadata_ids The metadata ids to navigate
    // @param metadata_array_len The length of metadata array
    // @param metadata_array The array with metadatas to store
    func createClassMetadataBatch(
            class_ids_len: felt, class_ids: felt*, metadata_ids_len: felt, metadata_ids: felt*,
            metadata_array_len: felt, metadata_array: ClassMetadata*
        ) {
    }

    // @notice Creates the metadata for a given unit
    // @param class_id The length of unit ids array
    // @param unit_id The unit id to store
    // @param metadata_id The metadata id to store
    // @param metadata The metadata to store
    func createUnitMetadata(class_id: felt, unit_id: felt, metadata_id: felt, metadata: UnitMetadata) {
    }

    // @notice Creates the metadata for a batch of units
    // @param class_ids_len The length of class ids array
    // @param class_ids The class ids to navigate
    // @param unit_ids_len The length of unit ids array
    // @param unit_ids The unit ids to navigate
    // @param metadata_ids_len The length of metadata ids array
    // @param metadata_ids The metadata ids to navigate
    // @param metadata_array_len The length of metadata array
    // @param metadata_array The array with metadatas to store
    func createUnitMetadataBatch(
            class_ids_len: felt, class_ids: felt*, unit_ids_len: felt, unit_ids: felt*,
            metadata_ids_len: felt, metadata_ids: felt*,
            metadata_array_len: felt, metadata_array: UnitMetadata*
        ) {
    }

    // @notice Creates a class
    // @param class_id The id of a new class, should be obtained prior to this action
    // @param metadata_ids_len The length of metadata ids array
    // @param metadata_ids The metadata ids to navigate
    // @param values_len The length of an array containing values
    // @param values The actual values to store
    func createClass(
            class_id: felt, metadata_ids_len: felt, metadata_ids: felt*, values_len: felt, values: Values*
        ) {
    }

    // @notice Creates a unit
    // @param class_id The id of a new unit, should be obtained prior to this action
    // @param metadata_ids_len The length of metadata ids array
    // @param metadata_ids The metadata ids to navigate
    // @param values_len The length of an array containing values
    // @param values The actual values to store
    func createUnit(
            class_id: felt, unit_id: felt, metadata_ids_len: felt, metadata_ids: felt, values_len: felt, values: Values*
        ) {
    }

    // @notice Updates the latest unit for a given class
    // @param class_id The id of a class
    // @param latest_unit_id The latest id of the unit
    // @param latest_unit_timestamp The Unix timestamp
    func updateClassLatestUnit(class_id: felt, latest_unit_id: felt, latest_unit_timestamp: felt) {
    }

    // @notice Return the `caller` current balance for a certain Unit
    // @param class_id The unique ID of a particular Class
    // @param unit_id The unique ID of a particular Unit
    func balanceOf(account: felt, class_id: felt, unit_id: felt) -> (balance: felt) {
    }

    // @notice Returns the remaining amount of tokens `spender` is allowed to spend
    // @param owner The address which is allowing `spender` to spend some amount of `owner` tokens
    // @param spender The address which is going to be allowed for spending tokens
    // @param class_id The unique ID of a particular Class
    // @param unit_id The unique ID of a particular Unit
    // @returns The remaining allowance
    func allowance(owner: felt, spender: felt, class_id: felt, unit_id: felt) -> (remaining: felt) {
    }

    // @notice Returns the metamodel of a certain Class
    // @param class_id The unique ID of a particular Class
    // @param metadata_id The unique ID of a particular trait of the given Class
    // @returns The class metadata
    func getClassMetadata(class_id: felt, metadata_id: felt) -> (classMetadata: ClassMetadata) {
    }

    // @notice Returns the metamodel of a certain Unit
    // @param class_id The unique ID of a particular Class
    // @param unit_id The unique ID of a particular Unit
    // @param metadata_id The unique ID of a particular trait of the given Unit
    func getUnitMetadata(class_id: felt, unit_id: felt, metadata_id: felt) -> (
        unitMetadata: UnitMetadata
    ) {
    }

    // @notice Returns the actual data of a certain Class
    // @param class_id The unique ID of a particular Class
    // @param metadata_id The unique ID of a particular trait of the given Class
    func getClassData(class_id: felt, metadata_id: felt) -> (classData: Values) {
    }

    // @notice Returns the actual data of a certain Unit
    // @param unit_id The unique ID of a particular Unit
    // @param metadata_id The unique ID of a particular trait of the given Unit
    func getUnitData(class_id: felt, unit_id: felt, metadata_id: felt) -> (unitData: Values) {
    }

    // @notice Returns the quantity of minted tokens for a certain Unit
    // @param class_id The unique ID of a particular Class
    // @param unit_id The unique ID of a particular Unit
    func totalSupply(class_id: felt, unit_id: felt) -> (balance: felt) {
    }

    // @notice Returns the current progress of a Unit execution
    // @param class_id The unique ID of a particular Class
    // @param unit_id The unique ID of a particular Unit
    func getProgress(class_id: felt, unit_id: felt) -> (progress: felt) {
    }
}
