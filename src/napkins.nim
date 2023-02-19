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

  Chat* = object

  Slot* = object
    present*: bool
    itemId*: Option[int32]
    itemCount*: Option[uint8]
    nbtData*: Option[NBT]

  Rotation* = object
    x*, y*, z*: float32

  Position* = object
    x*, z*: int32
    y*: int16

  Direction* = enum
    dirDown, dirUp, dirNorth, dirSouth, dirWest, dirEast

  NBT* = object # TODO: Implement this in a separate library, a library exists but our own impl would likely be better

  Particle* = object # TODO: Implement this

  VillagerData* = object
    typ*, profession*, level*: int32

  Pose* = enum
    pStanding, pFallFlying, pSleeping, pSwimming, pSpinAttack, pSneaking,
    pLongJumping, pDying, pCroaking, pUsingTongue, pSitting, pRoaring,
    pSniffing, pEmerging, pDigging

  Identifier* = object
    namespace*, id*: string

  GlobalPosition* = object
    identifier*: Identifier
    Position*: Position

  EntityMetadataType* = enum
    emtByte, emtVarInt, emtVarLong, emtFloat, emtString, emtChat, emtOptChat,
    emtSlot, emtBool, emtRotation, emtPosition, emtOptPosition, emtDirection,
    emtOptUuid, emtOptBlockId, emtNbt, emtParticle, emtVillagerData,
    emtOptVarInt, emtPose, emtCatVariant, emtFrogVariant, emtGlobalPosition,
    emtPaintingVariant

  EntityMetadata* = object # Using as a reference https://wiki.vg/Entity_metadata#Entity_Metadata_Format
    index*: uint8
    case typ*: EntityMetadataType
    of emtByte: valByte*: uint8
    of emtVarInt: valVarInt*: int32
    of emtVarLong: valVarLong*: int64
    of emtFloat: valFloat*: float
    of emtString: valString*: string
    of emtChat: valChat*: Chat
    of emtOptChat: valOptChat*: Option[Chat]
    of emtSlot: valSlot*: Slot
    of emtBool: valBool*: bool
    of emtRotation: valRotation*: Rotation
    of emtPosition: valPosition*: Position
    of emtOptPosition: valOptPosition*: Option[Position]
    of emtDirection: valDirection*: Direction
    of emtOptUuid: valOptUuid*: Option[UUID]
    of emtOptBlockId: valOptBlockId*: OptBlockId
    of emtNbt: valNbt*: NBT
    of emtParticle: valParticle*: Particle
    of emtVillagerData: valVillagerData*: VillagerData
    of emtOptVarInt: valOptVarInt*: Option[int32]
    of emtPose: valPose*: Pose
    of emtCatVariant: valCatVariant*: int32
    of emtFrogVariant: valFrogVariant*: int32
    of emtGlobalPosition: valGlobalPosition*: GlobalPosition
    of emtPaintingVariant: valPaintingVariant*: int32

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
