-- HGSS_SPRITES option schema.
--
-- Kept in its own module so the entry chunk can focus on runtime hooks. The
-- factory receives the generation predicate because Gen 1 and Gen 2 expose
-- different battle-art controls.
return function(isGen2)
  local rows = {}
  if isGen2() then
    rows[#rows + 1] = {
      key = "battle_trainer_gen",
      label = "TRAINER ART",
      type = "choice",
      default = "hgss",
      choices = {
        { "HGSS", "hgss" },
        { "ROM", "rom" },
      },
    }
  else
    rows[#rows + 1] = {
      key = "battle_scope",
      label = "BATTLE ART SCOPE",
      type = "choice",
      default = "trainers",
      choices = {
        { "TRAINERS ONLY", "trainers" },
        { "COMPLETE", "complete" },
      },
    }
    rows[#rows + 1] = {
      key = "battle_front_gen",
      label = "BATTLE FRONT GEN",
      type = "choice",
      default = "gen5",
      choices = {
        { "ROM", "rom" }, { "GEN 5 ANIMATED", "gen5" },
      },
    }
    rows[#rows + 1] = {
      key = "battle_back_gen",
      label = "BATTLE BACK GEN",
      type = "choice",
      default = "gen5",
      choices = {
        { "ROM", "rom" }, { "GEN 5 ANIMATED", "gen5" },
      },
    }
    rows[#rows + 1] = {
      key = "battle_trainer_gen",
      label = "TRAINER ART",
      type = "choice",
      default = "hgss",
      choices = {
        { "HGSS", "hgss" },
        { "ROM", "rom" },
      },
    }
  end

  rows[#rows + 1] = {
    key = "player_select",
    label = "PLAYER SELECT",
    type = "choice",
    default = "red",
    choices = {
      { "RED", "red" },
      { "ASH", "ash" },
      { "ETHAN", "ethan" },
      { "LYRA", "lyra" },
      { "KRIS", "kris" },
      { "KRIS V2", "kris_v2" },
      { "LEAF", "leaf" },
      { "BRENDAN", "brendan" },
      { "OFF", "off" },
    },
  }
  rows[#rows + 1] = {
    key = "party_menu",
    label = "PARTY MENU",
    type = "toggle",
    default = true,
  }
  rows[#rows + 1] = {
    key = "pc_box_icons",
    label = "PC BOX ICONS",
    type = "toggle",
    default = true,
  }
  rows[#rows + 1] = {
    key = "crisp_display",
    label = "CRISP DISPLAY",
    type = "toggle",
    default = false,
  }
  rows[#rows + 1] = {
    key = "sprite_size",
    label = "SPRITE SIZE",
    type = "choice",
    default = "0.8",
    choices = {
      { "0.5x", "0.5" },
      { "0.6x", "0.6" },
      { "0.7x", "0.7" },
      { "0.8x", "0.8" },
      { "0.9x", "0.9" },
      { "1.0x", "1.0" },
    },
  }
  rows[#rows + 1] = {
    key = "voxel_y_offset",
    label = "VOXEL Y OFFSET",
    type = "choice",
    default = "-5",
    choices = {
      { "-1 px", "-1" },
      { "-2 px", "-2" },
      { "-3 px", "-3" },
      { "-4 px", "-4" },
      { "-5 px", "-5" },
    },
  }
  return rows
end
