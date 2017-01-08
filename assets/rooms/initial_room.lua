return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 10,
  height = 10,
  tilewidth = 16,
  tileheight = 16,
  properties = {
    ["use_lights"] = "false"
  },
  tilesets = {
  },
  layers = {
    {
      type = "tilelayer",
      name = "foreground",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      properties = {
        ["type"] = "foreground"
      },
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "walls",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {}
    },
    {
      type = "objectgroup",
      name = "objects",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "ObjChar",
          shape = "rectangle",
          x = 32,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "ObjDebugCamera",
          shape = "rectangle",
          x = 80,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "Object Layer 3",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "ObjRoomChanger",
          shape = "rectangle",
          x = 0,
          y = 16,
          width = 64,
          height = 64,
          visible = true,
          properties = {
          -- ["newX"] = "62",
          -- ["newY"] = "-20",
          -- ["nextRoom"] = "ASPeak"
          ["nextX"] = "5",
          ["nextY"] = "24",
          ["nextRoom"] = "Entrance"
          -- ["newX"] = "22",
          -- ["newY"] = "19",
          -- ["nextRoom"] = "testRoom"
          -- ["newX"] = "36",
          -- ["newY"] = "42",
          -- ["nextRoom"] = "MRObservatory2"
          -- ["newX"] = "20",
          -- ["newY"] = "21",
          -- ["nextRoom"] = "HBTest"
            -- ["newX"] = "15",
            -- ["newY"] = "8",
            -- ["nextRoom"] = "ASRuins"
            -- ["newX"] = "140",
            -- ["newY"] = "8",
            -- ["nextRoom"] = "ASDarkForest"
            -- ["newX"] = "6",
            -- ["newY"] = "12",
            -- ["nextRoom"] = "Ausin_passageway"
            -- ["newX"] = "108",
            -- ["newY"] = "5",
            -- ["nextRoom"] = "Ausin_hospital"
            -- ["newX"] = "96",
            -- ["newY"] = "43",
            -- ["nextRoom"] = "Ausin_hospital"
            -- ["newX"] = "52",
            -- ["newY"] = "25",
            -- ["nextRoom"] = "TSOutside"
            -- ["newX"] = "22",
            -- ["newY"] = "30",
            -- ["nextRoom"] = "TSBridge"         
            -- ["newX"] = "40",
            -- ["newY"] = "30",
            -- ["nextRoom"] = "SSTest"
            -- ["newX"] = "13",
            -- ["newY"] = "24",
            -- ["nextRoom"] = "Suitcase"
          }
        }
      }
    }
  }
}

