-- https://lua.expert/
return function(p1) --[[ Line: 1 ]]
    local v1 = require(script.MissionPacket)(p1)

    p1:CreateEvent("FX", p1.PacketNetworking.Any)
    p1:CreateEvent("EmitParticles", p1.PacketNetworking.Instance)
    p1:CreateEvent("StyleChangeNotifier", p1.PacketNetworking.String, p1.PacketNetworking.String)
    p1:CreateEvent("LocalDestroy", p1.PacketNetworking.Instance, p1.PacketNetworking.NumberF16)
    p1:CreateEvent("KnockbackUpdate", {
        Id = p1.PacketNetworking.NumberS8,
        Speed = p1.PacketNetworking.Any,
        VelocityType = p1.PacketNetworking.String,
        Duration = p1.PacketNetworking.NumberF16,
        UpdateVelocityTimestamps = p1.PacketNetworking.Any,
        UpdateVelocityVector = p1.PacketNetworking.Any,
        MaxForce = p1.PacketNetworking.Vector3F32,
        InitialVelocity = p1.PacketNetworking.Any,
        PlayerUpdate = p1.PacketNetworking.Boolean8
    })
    p1:CreateEvent("RerollReiatsuColor"):Response(p1.PacketNetworking.Boolean8, p1.PacketNetworking.Color3)
    p1:CreateEvent("DestroyKnockback", p1.PacketNetworking.NumberS8)
    p1:CreateEvent("ClearBodyMovers")
    p1:CreateEvent("DebugConsole", { p1.PacketNetworking.StringLong })
    p1:CreateEvent("ToggleClanCosmetics")
    p1:CreateEvent("CancelMissionQueue")
    p1:CreateEvent("TeleportToPlayer", p1.PacketNetworking.String):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("ClaimTitle", p1.PacketNetworking.NumberU8)
    p1:CreateEvent("RemoveSpiritCharm", p1.PacketNetworking.NumberU8)
    p1:CreateEvent("RemoveHollowTrait", p1.PacketNetworking.NumberU8):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("UpdateGuildPermissions", p1.PacketNetworking.Any):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("CreateGuildBase", p1.PacketNetworking.String, p1.PacketNetworking.NumberU8):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("PlaceObject_GuildBase", p1.PacketNetworking.NumberU8, p1.PacketNetworking.CFrameF32U16)
    p1:CreateEvent("DestroyObject_GuildBase", p1.PacketNetworking.String):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("BuyPrefabs_GuildBase", {
        {
            Id = p1.PacketNetworking.NumberU8,
            Amount = p1.PacketNetworking.NumberS8
        }
    }):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("PromptGauntletSelection")
    p1:CreateEvent("PromptNewGamePlus")
    p1:CreateEvent("StartGauntlet", p1.PacketNetworking.NumberU8):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("GetAvailableGauntlets"):Response({ p1.PacketNetworking.NumberU8 })
    p1:CreateEvent("StartGauntletTimer", p1.PacketNetworking.NumberF32)
    p1:CreateEvent("EndGauntletTimer", p1.PacketNetworking.NumberF32)
    p1:CreateEvent("AttemptPrestige"):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("LightAttack", p1.PacketNetworking.Any, p1.PacketNetworking.Any)
    p1:CreateEvent("GetOnlineData", { p1.PacketNetworking.String }):Response({
        { p1.PacketNetworking.String, p1.PacketNetworking.String, p1.PacketNetworking.String }
    })
    p1:CreateEvent("AfkRewardVisuals", {
        Points = p1.PacketNetworking.NumberU8,
        Items = p1.PacketNetworking.Any
    })
    p1:CreateEvent("GiveMission", v1)
    p1:CreateEvent("UpdateControlMode", p1.PacketNetworking.String)
    p1:CreateEvent("RequestPromotionTask")
    p1:CreateEvent("UpdateMissionInfo", {
        Description = p1.PacketNetworking.StringLong,
        Success = p1.PacketNetworking.Any,
        Failed = p1.PacketNetworking.Any
    })
    p1:CreateEvent("UpdateMission", p1.PacketNetworking.String, p1.PacketNetworking.Any)
    p1:CreateEvent("UpdateMissionChallenges", {
        Challenges = v1.Challenges
    })
    p1:CreateEvent("ExtractionEffectGained")
    p1:CreateEvent("ExtractionEffectLost")
    p1:CreateEvent("AddMissionMarker", {
        { p1.PacketNetworking.Instance, p1.PacketNetworking.String }
    })
    p1:CreateEvent("RemoveMissionMarker", { p1.PacketNetworking.String })
    p1:CreateEvent("RemoveMission")
    p1:CreateEvent("StatusEffectSignals", p1.PacketNetworking.NumberU8, p1.PacketNetworking.String)
    p1:CreateEvent("ParryIndicator", p1.PacketNetworking.String, p1.PacketNetworking.Any)
    p1:CreateEvent("OpenJournalExtract", p1.PacketNetworking.NumberU8)
    p1:CreateEvent("AttemptTrade", p1.PacketNetworking.Instance)
    p1:CreateEvent("ProcessDamage", p1.PacketNetworking.NumberU8)
    p1:CreateEvent("TradeStart", p1.PacketNetworking.Instance, p1.PacketNetworking.Instance, { p1.PacketNetworking.Any })
    p1:CreateEvent("ResetControlScheme")
    p1:CreateEvent("UpdateControlScheme", {
        Mode = p1.PacketNetworking.String,
        Bind = { p1.PacketNetworking.String },
        BindName = p1.PacketNetworking.String
    })
    p1:CreateEvent("GetGuildMembers", {
        GuildId = p1.PacketNetworking.String
    }):Response({ p1.PacketNetworking.Any })
    p1:CreateEvent("GuildAction_Player", {
        Action = p1.PacketNetworking.String,
        MemberId = p1.PacketNetworking.String
    }):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("BuyGuildUpgrade", p1.PacketNetworking.String):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("DepositGuildFunds", p1.PacketNetworking.NumberF32):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("InvitePlayerToWager", p1.PacketNetworking.NumberS32):Response({ p1.PacketNetworking.NumberS32 }).ResponseTimeout = 60
    p1:CreateEvent("CreateParty"):Response({ p1.PacketNetworking.NumberS32 })
    p1:CreateEvent("CreateParty_Client"):Response(p1.PacketNetworking.Boolean8)
    p1:CreateEvent("DestroyParty")
    p1:CreateEvent("SendWager", {
        GuildId = p1.PacketNetworking.String,
        Amount = p1.PacketNetworking.NumberS32
    })
    p1:CreateEvent("YesNoPrompt", {
        PromptName = p1.PacketNetworking.String,
        Description = p1.PacketNetworking.String,
        ExpiryTime = p1.PacketNetworking.Any
    }):Response(p1.PacketNetworking.Any).ResponseTimeout = 60
    p1:CreateEvent("MultiChoicePrompt", {
        PromptName = p1.PacketNetworking.String,
        Answers = { p1.PacketNetworking.String }
    }):Response(p1.PacketNetworking.Any).ResponseTimeout = 60
    p1:CreateEvent("CustomAmountPrompt", {
        PromptName = p1.PacketNetworking.String,
        PromptAmountFields = p1.PacketNetworking.Any,
        PlaceholderFieldText = p1.PacketNetworking.Any,
        Answers = { p1.PacketNetworking.String }
    }):Response(p1.PacketNetworking.Any).ResponseTimeout = 60
    p1:CreateFXEvent("ParryShine", {
        Character = p1.PacketNetworking.Instance,
        Hakuda = p1.PacketNetworking.Boolean8,
        Limb = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("CellSpawnIn", p1.PacketNetworking.Instance)
    p1:CreateFXEvent("ReishiGunShot", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        Color = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("ReishiGunShot_HeavyAttack", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        Color = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("MenosM1", {
        RootCFrame = p1.PacketNetworking.CFrameF24U8,
        Position = p1.PacketNetworking.Vector3F32,
        CurrentAttack = p1.PacketNetworking.NumberU8
    })
    p1:CreateFXEvent("RifleM1", {
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("GreatswordM1Slam", {
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("HighlightFlash", {
        Character = p1.PacketNetworking.Instance,
        Color = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("CritStartupEffect", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("KatanaCrit", {
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("Dragonlash", p1.PacketNetworking.CFrameF24U8)
    p1:CreateFXEvent("DropKick", p1.PacketNetworking.CFrameF24U8)
    p1:CreateFXEvent("SweepKick", p1.PacketNetworking.CFrameF24U8)
    p1:CreateFXEvent("DownslamFX", p1.PacketNetworking.Vector3F32)
    p1:CreateFXEvent("BalaDiscSummon", p1.PacketNetworking.Instance, p1.PacketNetworking.Color3)
    p1:CreateFXEvent("BossZoneIndicator_Box", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        Size = p1.PacketNetworking.Vector3F32,
        Duration = p1.PacketNetworking.NumberF16,
        Color = p1.PacketNetworking.Any,
        PlaySound = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("BossZoneIndicator_Circle", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        Size = p1.PacketNetworking.Vector3F32,
        Duration = p1.PacketNetworking.NumberF16,
        Color = p1.PacketNetworking.Any,
        PlaySound = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("DeathBleed", {
        Character = p1.PacketNetworking.Instance,
        Duration = p1.PacketNetworking.NumberU8,
        Direction = p1.PacketNetworking.Any,
        MinAmount = p1.PacketNetworking.NumberS8,
        MaxAmount = p1.PacketNetworking.NumberS8,
        WaitTime = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BloodHit", {
        Position = p1.PacketNetworking.Vector3F32,
        Big = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("HeavyKnockbackEffect", {
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("HakudaSwingEffect", {
        RootPart = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("PlayLocalSound", p1.PacketNetworking.Instance)
    p1:CreateFXEvent("HeavyKick", {
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("EvoRifleCrit", p1.PacketNetworking.Instance, p1.PacketNetworking.NumberU8)
    p1:CreateFXEvent("SpawnSenkaimon", {
        CFrame = p1.PacketNetworking.CFrameF32U16,
        Duration = p1.PacketNetworking.NumberU8
    })
    p1:CreateFXEvent("BlacksmithHit", p1.PacketNetworking.Instance)
    p1:CreateFXEvent("ByakuraiEffect", p1.PacketNetworking.CFrameF24U8)
    p1:CreateFXEvent("FlashStepEffect", {
        Character = p1.PacketNetworking.Instance,
        Race = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("Shunpo", {
        Character = p1.PacketNetworking.Instance,
        Race = p1.PacketNetworking.String,
        Electric = p1.PacketNetworking.Boolean8,
        ElectricColor = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("FlashStrike", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("EvoSpearCrit", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("AirFlipMovement", {
        Character = p1.PacketNetworking.Instance,
        EndCF = p1.PacketNetworking.CFrameF24U8,
        TweenDur = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("NotMyType", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("EmperorsReign", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("EvoSwordCrit", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("PortalEffect", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("BloodTax", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("RoundKick", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("Shinten", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("WaypointKick", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BruteForce", {
        Character = p1.PacketNetworking.Instance,
        SlashSpeed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("ImpaleHit", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("SurgeFist", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        ReiatsuColor = p1.PacketNetworking.Color3,
        AirVariant = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("SurgeFistExplosion", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        ReiatsuColor = p1.PacketNetworking.Color3,
        Scale = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BlastPunisher", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("BlastPunisherDash", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        ReiatsuColor = p1.PacketNetworking.Color3,
        Enemy = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("PsychoCrash", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("CLTHollow", {
        Character = p1.PacketNetworking.Instance,
        String = p1.PacketNetworking.String,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("LightShot", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        Speed = p1.PacketNetworking.NumberF16,
        Repeats = p1.PacketNetworking.NumberU8,
        Range = p1.PacketNetworking.NumberF16,
        FireDelay = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("HapticEffect", {
        HapticEffect = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("FinalBreath", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("WaypointMarker", {
        Character = p1.PacketNetworking.Instance,
        CFrame = p1.PacketNetworking.CFrameF24U8,
        Duration = p1.PacketNetworking.NumberF16,
        Range = p1.PacketNetworking.NumberF16,
        AbilityVariant = p1.PacketNetworking.String,
        Concealed = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("WaypointTarget", {
        Character = p1.PacketNetworking.Instance,
        Target = p1.PacketNetworking.Instance,
        Duration = p1.PacketNetworking.NumberF16,
        Range = p1.PacketNetworking.NumberF16,
        AbilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("WaypointExplode", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        AbilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("BlademasterM2", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BlademasterScreen", {})
    p1:CreateFXEvent("DestructibleHitEffect", {
        Model = p1.PacketNetworking.Instance,
        Position = p1.PacketNetworking.Vector3F32,
        Color = p1.PacketNetworking.Color3,
        DestructibleType = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("Ressureccion", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("EvolveEffect", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        ReiatsuColor = p1.PacketNetworking.Color3,
        isMenos = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("ArrancarAwaken", {
        Character = p1.PacketNetworking.Instance,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("LetztStil", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("QuincySummon", {
        Character = p1.PacketNetworking.Instance,
        ToParent = p1.PacketNetworking.Instance,
        SizeMultiplier = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("MedallionSummon", {
        Character = p1.PacketNetworking.Instance,
        ToParent = p1.PacketNetworking.Instance,
        SizeMultiplier = p1.PacketNetworking.NumberF16,
        EvolvedWeapon = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("HolyLightning", {
        Character = p1.PacketNetworking.Instance,
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("HeiligVerbegun", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("StarFlash", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("StarLariat", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("SuperstarCheer", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        Mode = p1.PacketNetworking.Boolean8,
        Mini = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("MaskedWarriorBlast", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("WrestlingHeavy", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BowFireVisuals", {
        Character = p1.PacketNetworking.Instance,
        FireDelay = p1.PacketNetworking.NumberF16,
        UseBladePoint = p1.PacketNetworking.Boolean8,
        SizeMultiplier = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BowChargeVisuals", {
        Character = p1.PacketNetworking.Instance,
        ToParent = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("FadeToTargetTransparency", {
        Model = p1.PacketNetworking.Instance,
        Duration = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("BlutVeneHitEffect", {
        Character = p1.PacketNetworking.Instance,
        Highlight = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("GrapplersGambit", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("Fushibi", {
        Character = p1.PacketNetworking.Instance,
        CFrame = p1.PacketNetworking.CFrameF24U8,
        XSize = p1.PacketNetworking.NumberF16,
        ZSize = p1.PacketNetworking.NumberF16,
        PointsNum = p1.PacketNetworking.NumberS8
    })
    p1:CreateFXEvent("KidoIncantation", {
        Character = p1.PacketNetworking.Instance,
        Text = p1.PacketNetworking.String,
        IncantationTitle = p1.PacketNetworking.Any,
        TextColor = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("DeathEffect", {
        Model = p1.PacketNetworking.Instance,
        Color = p1.PacketNetworking.Any,
        Race = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("Sokatsui", {
        Character = p1.PacketNetworking.Instance,
        ChargeTime = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("RockCharm", {
        character = p1.PacketNetworking.Instance,
        duration = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("IronSkin", {
        character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("LightOrbs", {
        character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        duration = p1.PacketNetworking.NumberF16,
        orbCount = p1.PacketNetworking.NumberU8
    })
    p1:CreateFXEvent("FlawlessCharm", {
        character = p1.PacketNetworking.Instance,
        ability = p1.PacketNetworking.String,
        abilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("TerrorCharm", {
        character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("ShikaiActivate", {
        Character = p1.PacketNetworking.Instance,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("TweenTransparencies", {
        { p1.PacketNetworking.Instance, p1.PacketNetworking.NumberF16 }
    }, p1.PacketNetworking.NumberF16)
    p1:CreateFXEvent("BlockFX", {
        Position = p1.PacketNetworking.Vector3F32,
        PostureDamage = p1.PacketNetworking.NumberU8,
        Color = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("GuardbreakFX", {
        Position = p1.PacketNetworking.Vector3F32,
        Overwhelming = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("BlockFX_Blunt", {
        Position = p1.PacketNetworking.Vector3F32,
        Sharp = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("BalaBlaster", {
        character = p1.PacketNetworking.Instance,
        speed = p1.PacketNetworking.NumberF16,
        reiColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("DimensionalHighlight", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("DeflectParticles", {
        Position = p1.PacketNetworking.Vector3F32,
        PostureDamage = p1.PacketNetworking.NumberF16,
        BluntParry = p1.PacketNetworking.Boolean8,
        NeutralDeflected = p1.PacketNetworking.Boolean8,
        ArterieActive = p1.PacketNetworking.Boolean8,
        TsuzuriParry = p1.PacketNetworking.Boolean8,
        HighPostureParry = p1.PacketNetworking.Boolean8,
        BaseAttack = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("BladeFlow", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        Duration = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("UpwardsKick", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("WhirlwindCutter", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("VortexEdge", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("HuntingDash", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("SavageCrossCut1", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("SavageCrossCut2", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("UpAndDown", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("PrayingMantisCrit", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("HolyWailing", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("MetalSpikes", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("MetalArmForm", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("SpikeClamp", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("MetalBackhand", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("LeichterSturm", {
        character = p1.PacketNetworking.Instance,
        fireDur = p1.PacketNetworking.NumberF16,
        drawString = p1.PacketNetworking.Instance,
        hits = p1.PacketNetworking.NumberU8,
        moveSpeed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("HollowCutterFX", {
        string = p1.PacketNetworking.String,
        model = p1.PacketNetworking.Instance,
        color = p1.PacketNetworking.Any,
        projectile = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("DangerEffect", {
        Character = p1.PacketNetworking.Instance,
        DangerType = p1.PacketNetworking.String,
        PartName = p1.PacketNetworking.Any,
        Offset = p1.PacketNetworking.Any,
        Size = p1.PacketNetworking.NumberF16,
        PlaySound = p1.PacketNetworking.Boolean8
    })
    p1:CreateFXEvent("StaggerKicks", p1.PacketNetworking.Instance)
    p1:CreateFXEvent("IcePillar", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        StartPos = p1.PacketNetworking.Vector3F32,
        ResultPos = p1.PacketNetworking.Vector3F32
    })
    p1:CreateFXEvent("PunisherDrive", {
        Character = p1.PacketNetworking.Instance,
        Target = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("DefaultBladeSnap", {
        Character = p1.PacketNetworking.Instance,
        Target = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("MedallionCrack", {
        Character = p1.PacketNetworking.Instance,
        Target = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("ArmDetach", {
        Character = p1.PacketNetworking.Instance,
        Target = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("FirstBurnerFinger", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        SpawnCF = p1.PacketNetworking.CFrameF24U8,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("SecondBurnerFinger", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("ThirdBurnerFinger", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("FourthBurnerFinger", {
        Character = p1.PacketNetworking.Instance,
        AbilityVariant = p1.PacketNetworking.String,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("RoarLoop", {
        Character = p1.PacketNetworking.Instance,
        Position = p1.PacketNetworking.Vector3F32,
        RayDistance = p1.PacketNetworking.NumberF16,
        SizeMulti = p1.PacketNetworking.NumberF16,
        Offset = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("FlameShikaiFX", {
        Character = p1.PacketNetworking.Instance,
        string = p1.PacketNetworking.String,
        AbilityVariant = p1.PacketNetworking.String,
        position = p1.PacketNetworking.Vector3F32
    })
    p1:CreateFXEvent("FlowerVisuals", {
        character = p1.PacketNetworking.Instance,
        string = p1.PacketNetworking.String,
        speed = p1.PacketNetworking.NumberF16,
        position = p1.PacketNetworking.Any,
        duration = p1.PacketNetworking.Any
    })
    p1:CreateFXEvent("FlowerScreen", {})
    p1:CreateFXEvent("DimensionalScreen1", {})
    p1:CreateFXEvent("DimensionalScreen2", {
        Repeats = p1.PacketNetworking.NumberU8,
        DelayBetween = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("GroundSlamVisuals", {
        root = p1.PacketNetworking.Instance,
        string = p1.PacketNetworking.String,
        speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("DragonFist", {
        Character = p1.PacketNetworking.Instance,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("DragonFist_Part2", {
        Character = p1.PacketNetworking.Instance,
        Model = p1.PacketNetworking.Instance,
        ReiatsuColor = p1.PacketNetworking.Color3
    })
    p1:CreateFXEvent("BreakerFist", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("AriseEffect", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        AbilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("BaseFinisher", {
        Character = p1.PacketNetworking.Instance,
        Victim = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("FlyingCyclone", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("FlyingCycloneProjectile", {
        Projectile = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("360Slash", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("360Lightning", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("360Gelum", {
        Position = p1.PacketNetworking.Vector3F32,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("Schlagen", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16,
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("BossSummon", {
        CFrame = p1.PacketNetworking.CFrameF24U8
    })
    p1:CreateFXEvent("Incinerator", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("Tenran", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("KeroseneSlam", {
        Character = p1.PacketNetworking.Instance,
        Target = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("FalseCutter", {
        Character = p1.PacketNetworking.Instance,
        Type = p1.PacketNetworking.String,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("ThrustFX", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("TempestCombo", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("Hainawa", {
        Character = p1.PacketNetworking.Instance
    })
    p1:CreateFXEvent("SwingingThrow_OnGrab", {
        Character = p1.PacketNetworking.Instance,
        Speed = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("IceFreeze", {
        CFrame = p1.PacketNetworking.CFrameF24U8,
        AbilityVariant = p1.PacketNetworking.String
    })
    p1:CreateFXEvent("FadeParts", {
        Model = p1.PacketNetworking.Instance,
        Duration = p1.PacketNetworking.NumberF16
    })
    p1:CreateFXEvent("MuayThaiCrit2", {
        Model = p1.PacketNetworking.Instance
    })
end
