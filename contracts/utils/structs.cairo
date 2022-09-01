%lang starknet


struct Values:
    member uintValue : felt
    member stringValue : felt
    member addressValue : felt
    member boolValue : felt
end

struct ClassMetadata:
    member name : felt
    member type : felt
    member description : felt
    member values : Values
end

struct UnitMetadata:
    member class : felt
    member name : felt
    member type : felt
    member description : felt
    member values : Values
end
struct Transaction:
    member class_id : felt
    member unit_id : felt
    member amount : felt
end