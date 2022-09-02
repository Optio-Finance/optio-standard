%lang starknet

from contracts.utils.structs import Transaction, ClassMetadata, UnitMetadata, Values

@contract_interface
namespace IOptio:
    func transferFrom(_from : felt, _to : felt, _transactions_len : felt, _transactions : Transaction*):
    end

    func transferAllowanceFrom(_from : felt, _to : felt, _transactions_len : felt, _transactions : Transaction*):
    end

    func issue(_to : felt, _transactions_len : felt, _transactions : Transaction*):
    end

    func redeem(_from : felt, _transactions_len : felt, _transactions : Transaction*):
    end

    func burn(_from : felt, _transactions_len : felt, _transactions : Transaction*):
    end

    func approve(owner : felt, spender : felt, transactions_len : felt, transactions : Transaction*):
    end

    func setApprovalFor(operator : felt, approved : felt):
    end

    func totalSupply(class_id : felt, unit_id : felt) -> (balance : felt):
    end

    func balanceOf(account : felt, class_id : felt, unit_id : felt) -> (balance : felt):
    end

    func getClassMetadata(class_id : felt, metadata_id : felt) -> (classMetadata : ClassMetadata):
    end

    func getUnitMetadata(class_id : felt, unit_id : felt, metadata_id : felt) -> (unitMetadata : UnitMetadata):
    end

    func getClassData(class_id : felt, metadata_id : felt) -> (classData : Values):
    end

    func getUnitData(class_id : felt, unit_id : felt, metadata_id : felt) -> (unitData : Values):
    end

    func getProgress(class_id : felt, unit_id : felt) -> (progress : felt):
    end

    func allowance(owner : felt, spender : felt, class_id : felt, unit_id : felt) -> (remaining : felt):
    end

    func isApprovedFor(owner : felt, operator : felt) -> (approved : felt):
    end
end