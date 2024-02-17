local OPTIONS = {NameTag=true, TextHeight = 1, HeightOffset = 4}

if ModOptions and ModOptions.getInstance then
    local settings = ModOptions:getInstance(OPTIONS, "2749928925", "TLOU_Zombie")
    local Height = settings:getData("TextHeight")
    local Offset = settings:getData("HeightOffset")
    local Tag = settings:getData("NameTag")
    Tag.tooltip = "IGUI_TLOU_NameTag_Tooltip"
    Tag.name = "IGUI_TLOU_NameTag"
    Height.tooltip = "IGUI_TLOU_TextHeight_Tooltip"
    Height.name = "IGUI_TLOU_TextHeight"
    Height[1] = getText("IGUI_TLOU_TextHeight1")
    Height[2] = getText("IGUI_TLOU_TextHeight2")
    Height[3] = getText("IGUI_TLOU_TextHeight3")
    Offset.name = "IGUI_TLOU_HeightOffset"
    Offset.tooltip = "IGUI_TLOU_HeightOffset_Tooltip"
    Offset[1] = getText("IGUI_TLOU_HeightOffset1")
    Offset[2] = getText("IGUI_TLOU_HeightOffset2")
    Offset[3] = getText("IGUI_TLOU_HeightOffset3")
    Offset[4] = getText("IGUI_TLOU_HeightOffset4")
    Offset[5] = getText("IGUI_TLOU_HeightOffset5")
    Offset[6] = getText("IGUI_TLOU_HeightOffset6")
    Offset[7] = getText("IGUI_TLOU_HeightOffset7")
    function Height:OnApplyInGame(val)
      print('Option is updated!', self.id, val)
    end
end

ZombieForgeOptions = OPTIONS