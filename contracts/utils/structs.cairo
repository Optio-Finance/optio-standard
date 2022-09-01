%lang starknet


struct ClassMetadata:
    member class_id : felt
    member metadata_id : felt
    member name : felt
    member type : felt
    member description : felt
end

struct UnitMetadata:
    member class_id : felt
    member unit_id : felt
    member metadata_id : felt
    member name : felt
    member type : felt
    member description : felt
end

struct Values:
    member uint : felt
    member string : felt
    member address : felt
    member boolean : felt
    member timestamp : felt
    member uri : felt
end

struct Class:
    member class_id : felt
    member name : felt
    member type : felt
    member description : felt
    member values : Values
end

struct Unit:
    member class_id : felt
    member unit_id : felt
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