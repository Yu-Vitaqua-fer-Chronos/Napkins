import std/[
  options, # Used for optional types
  json,    # We use std/json to parse the protocol files
  os       # Used so we can get the directory the package is installed in
]

from uuid import UUID # Import this as we need to structure objects with UUIDs

var protocolJsonFolder = parentDir(currentSourcePath()) / "protocols"

var v1_19_3 = parseJson(readFile(protocolJsonFolder / "1-19-3.json"))

type
  Buffer* = distinct seq[byte] ## Purely to help tell the difference between different things in the packet handling

  NBT* = object # TODO: Implement this in a separate library, a library exists but our own is likely better

  Rotation* = object
    x*, y*, z*: float32

  Position* = object

  Direction* = enum
    dirDown, dirUp, dirNorth, dirSouth, dirWest, dirEast

  Slot* = object
    present*: bool
    itemId*: Option[int32]
    itemCount*: Option[uint8]
    nbtData*: Option[NBT]

  EntityMetadataType* = enum
    emtByte, emtVarInt, emtVarLong, emtFloat, emtString, emtChat, emtOptChat,
    emtSlot, emtBool, emtRotation, emtPosition, emtOptPosition, emtDirection


  EntityMetadata* = object # Using as a reference https://wiki.vg/Entity_metadata#Entity_Metadata_Format
    index: byte

  EntityMetadataLoop* = seq[EntityMetadata]

const TYPE_LOOKUP_TABLE = {
  "varint": "int32",
  "varlong": "int64",
  "pstring": "string",
  "buffer": "Buffer",
  "u8": "uint8",
  "u16": "uint16",
  "u32": "uint32",
  "u64": "uint64",
  "i8": "int8",
  "i16": "int16",
  "i32": "int32",
  "i64": "int64",
  "bool": "bool",
  "f32": "float32",
  "f64": "float64",
  "UUID": "UUID",
  "option": "option",
  "entityMetadataLoop": "EntityMetadataLoop",
  "topBitSetTerminatedArray": "seq[byte]"
}

for typ in v1_19_3["types"].keys:
  if v1_19_3["types"][typ].getStr() == "native":
    echo typ