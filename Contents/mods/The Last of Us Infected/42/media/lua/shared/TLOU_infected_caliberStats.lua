--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Stats for various weapons used to determine a gun's ability to kill an infected.

]]--
--[[ ================================================ ]]--

local CaliberData = {

--- Vanilla
	["Base.Bullets38"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   300,	Emax =   450,	Diameter =  9.06,	CanKill = true,	increaseHitTime = true, },
	["Base.223Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  1670,	Emax =  1890,	Diameter =  5.69,	CanKill = true,	increaseHitTime = true, },
	["Base.308Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  3800,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets44"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =  1000,	Emax =  1800,	Diameter =  10.9,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets45"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   483,	Emax =   676,	Diameter = 11.43,	CanKill = true,	increaseHitTime = true, },
	["Base.556Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  1670,	Emax =  1890,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets9mm"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   480,	Emax =   550,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },
	["Base.ShotgunShells"                     ]	=	{ AmmoType = "Shotgun"   ,	Emin =  2500,	Emax =  3300,	Diameter = 18.53,	CanKill = true,	increaseHitTime = true, },

--- VFE
	["Base.762Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.22Bullets"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   140,	Emax =   280,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.308BulletsLinked"                  ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  3800,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },

--- VFE Stalker
	["Base.545Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  1390,	Emax =  1890,	Diameter =   5.6,	CanKill = true,	increaseHitTime = true, },

--- Brita
	["Base.Bullets45LC"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   663,	Emax =   844,	Diameter = 11.43,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets357"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   780,	Emax =  1090,	Diameter =  9.06,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets380"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   275,	Emax =   360,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets57"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   500,	Emax =   600,	Diameter =   5.7,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets22"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   140,	Emax =   280,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets4570"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter = 11.63,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets50MAG"                      ]	=	{ AmmoType = "Bullet"    ,	Emin = 19000,	Emax = 19000,	Diameter = 12.98,	CanKill = true,	increaseHitTime = true, },
	["Base.545x39Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  1390,	Emax =  1890,	Diameter =   5.6,	CanKill = true,	increaseHitTime = true, },
	["Base.762x39Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.762x51Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2000,	Emax =  3850,	Diameter =  7.84,	CanKill = true,	increaseHitTime = true, },
	["Base.762x54rBullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =  2600,	Emax =  2800,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.3006Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  2800,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["Base.50BMGBullets"                      ]	=	{ AmmoType = "Bullet"    ,	Emin = 19000,	Emax = 19000,	Diameter = 12.98,	CanKill = true,	increaseHitTime = true, },
	["Base.40HERound"                         ]	=	{ AmmoType = "Projectile",	Emin = 20000,	Emax = 20000,	Diameter =  40.0,	CanKill = true,	increaseHitTime = true, },
	["Base.40INCRound"                        ]	=	{ AmmoType = "Projectile",	Emin = 15000,	Emax = 16000,	Diameter =  40.0,	CanKill = true,	increaseHitTime = true, },
	["Base.HERocket"                          ]	=	{ AmmoType = "Bullet"    ,	Emin = 30000,	Emax = 30000,	Diameter =  40.0,	CanKill = true,	increaseHitTime = true, },
	["Base.410gShotgunShells"                 ]	=	{ AmmoType = "Shotgun"   ,	Emin =  1000,	Emax =  1780,	Diameter =  10.4,	CanKill = true,	increaseHitTime = true, },
	["Base.20gShotgunShells"                  ]	=	{ AmmoType = "Shotgun"   ,	Emin =  1700,	Emax =  2400,	Diameter = 15.63,	CanKill = true,	increaseHitTime = true, },
	["Base.10gShotgunShells"                  ]	=	{ AmmoType = "Shotgun"   ,	Emin =  3000,	Emax =  3960,	Diameter = 19.69,	CanKill = true,	increaseHitTime = true, },
	["Base.4gShotgunShells"                   ]	=	{ AmmoType = "Shotgun"   ,	Emin =  5000,	Emax =  5500,	Diameter = 26.72,	CanKill = true,	increaseHitTime = true, },
	["Base.PB68"                              ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.BB177"                             ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.CO2_Cartridge"                     ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.FlameFuel"                         ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.Smoke"                             ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.WaterAmmo"                         ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.Flare"                             ]	=	{ AmmoType = "Other"     ,	Emin =     0,	Emax =     0,	Diameter =   0.0,	CanKill = false,	increaseHitTime = false, },
	["Base.SlingShotAmmo_Rock"                ]	=	{ AmmoType = "Projectile",	Emin =    50,	Emax =   250,	Diameter =  15.0,	CanKill = true,	increaseHitTime = false, },
	["Base.SlingShotAmmo_Marble"              ]	=	{ AmmoType = "Projectile",	Emin =    50,	Emax =   250,	Diameter =  15.0,	CanKill = true,	increaseHitTime = false, },

--- Firearms B41
	["Base.Bullets4440"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  1016,	Emax =  1016,	Diameter =  10.9,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets3006"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  2800,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },

--- Guns93
	["Base.Slugs"                             ]	=	{ AmmoType = "Shotgun"   ,	Emin =  3000,	Emax =  4000,	Diameter = 18.53,	CanKill = true,	increaseHitTime = true, },
	["Base.76239Bullets"                      ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.792Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  3800,	Emax =  4000,	Diameter =  8.22,	CanKill = true,	increaseHitTime = true, },
	["Base.10mmBullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   680,	Emax =   960,	Diameter = 10.17,	CanKill = true,	increaseHitTime = true, },
	["Base.40Bullets"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   600,	Emax =   800,	Diameter =  10.2,	CanKill = true,	increaseHitTime = true, },
	["Base.25Bullets"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =    90,	Emax =   200,	Diameter =  6.38,	CanKill = true,	increaseHitTime = true, },
	["Base.380Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   275,	Emax =   360,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },
	["Base.357Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   780,	Emax =  1090,	Diameter =  9.06,	CanKill = true,	increaseHitTime = true, },
	["Base.45LCBullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   663,	Emax =   844,	Diameter = 11.43,	CanKill = true,	increaseHitTime = true, },
	["Base.30CarBullets"                      ]	=	{ AmmoType = "Bullet"    ,	Emin =  1000,	Emax =  1400,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },
	["Base.3030Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  2450,	Emax =  2800,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["Base.556Belt"                           ]	=	{ AmmoType = "Bullet"    ,	Emin =  1670,	Emax =  1890,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.308Belt"                           ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  3800,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },

--- Pallontras Weapons
	["PWPNXB.WoodBolt"                        ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["PWPNXB.ShortWoodBolt"                   ]	=	{ AmmoType = "Projectile",	Emin =   150,	Emax =   300,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["PWPNXB.ShortIronBolt"                   ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["PWPNXB.IronBolt"                        ]	=	{ AmmoType = "Projectile",	Emin =   250,	Emax =   400,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },

--- Kitsune's Crossbow
	["KCMweapons.CrossbowBolt"                ]	=	{ AmmoType = "Projectile",	Emin =   150,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["KCMweapons.CrossbowBoltLarge"           ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   400,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["KCMweapons.WoodenBolt"                  ]	=	{ AmmoType = "Projectile",	Emin =   150,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },

--- Scrap Guns
	["SGuns.MetalScraps"                      ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =   3.0,	CanKill = true,	increaseHitTime = true, },
	["SGuns.ShrapnelShell"                    ]	=	{ AmmoType = "Shotgun"   ,	Emin =  1200,	Emax =  2400,	Diameter = 18.53,	CanKill = true,	increaseHitTime = true, },
	["SGuns.Sbullets"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =  1670,	Emax =  1890,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["SGuns.ScrapBullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =   140,	Emax =   280,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },

--- Advanced Warfare EX
	["Base.762x51_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =  2000,	Emax =  3850,	Diameter =  7.84,	CanKill = true,	increaseHitTime = true, },
	["Base.shotgun12G_shells"                 ]	=	{ AmmoType = "Shotgun"   ,	Emin =  2500,	Emax =  3300,	Diameter = 18.53,	CanKill = true,	increaseHitTime = true, },
	["Base.9mm_Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   480,	Emax =   550,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },
	["Base.308_Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  3800,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },
	["Base.556x45_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =  1670,	Emax =  1890,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.38_Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   300,	Emax =   450,	Diameter =  9.06,	CanKill = true,	increaseHitTime = true, },
	["Base.44_Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  1000,	Emax =  1800,	Diameter =  10.9,	CanKill = true,	increaseHitTime = true, },
	["Base.45_70_Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter = 11.63,	CanKill = true,	increaseHitTime = true, },
	["Base.545x39_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =  1390,	Emax =  1890,	Diameter =   5.6,	CanKill = true,	increaseHitTime = true, },
	["Base.380_Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   275,	Emax =   360,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },
	["Base.303B_Bullets"                      ]	=	{ AmmoType = "Bullet"    ,	Emin =  3000,	Emax =  3600,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.792x57Mauser_Bullets"              ]	=	{ AmmoType = "Bullet"    ,	Emin =  3800,	Emax =  4000,	Diameter =  8.22,	CanKill = true,	increaseHitTime = true, },
	["Base.50MAG_Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin = 19000,	Emax = 19000,	Diameter = 12.98,	CanKill = true,	increaseHitTime = true, },
	["Base.762x39_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.300BLK_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =   700,	Emax =  1900,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },
	["Base.Fury68_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =  3000,	Emax =  3700,	Diameter =  7.06,	CanKill = true,	increaseHitTime = true, },
	["Base.30_06_Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  2800,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["Base.357_Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   780,	Emax =  1090,	Diameter =  9.06,	CanKill = true,	increaseHitTime = true, },
	["Base.300WINMagnum_Bullets"              ]	=	{ AmmoType = "Bullet"    ,	Emin =  3500,	Emax =  4000,	Diameter =   7.8,	CanKill = true,	increaseHitTime = true, },
	["Base.50BMG_Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin = 19000,	Emax = 19000,	Diameter = 12.98,	CanKill = true,	increaseHitTime = true, },
	["Base.45_Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   483,	Emax =   676,	Diameter = 11.43,	CanKill = true,	increaseHitTime = true, },
	["Base.22_Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   140,	Emax =   280,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.CarbonFibre_Arrow"                 ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["Base.WoodenStick"                       ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["Base.9x18mm_Bullets"                    ]	=	{ AmmoType = "Bullet"    ,	Emin =   300,	Emax =   450,	Diameter =  9.27,	CanKill = true,	increaseHitTime = true, },
	["Base.223_Bullets"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =  1670,	Emax =  1890,	Diameter =  5.69,	CanKill = true,	increaseHitTime = true, },
	["Base.7_62x33Cmm_Bullets"                ]	=	{ AmmoType = "Bullet"    ,	Emin =  1200,	Emax =  1700,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },

--- EscapeFromKentucky2
	["Base.Bullets50"                         ]	=	{ AmmoType = "Bullet"    ,	Emin = 19000,	Emax = 19000,	Diameter = 12.98,	CanKill = true,	increaseHitTime = true, },
	["Base.bolt"                              ]	=	{ AmmoType = "Projectile",	Emin =   250,	Emax =   400,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets308"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  2500,	Emax =  3800,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },
	["Base.Nails"                             ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   300,	Diameter =   3.0,	CanKill = true,	increaseHitTime = true, },
	["Base.GrenadeAmmo"                       ]	=	{ AmmoType = "Projectile",	Emin = 20000,	Emax = 20000,	Diameter =  40.0,	CanKill = true,	increaseHitTime = true, },

--- Crossbow (Lactose)
	["LactoseCrossbow.LCCrossbowBoltAluminium"]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },
	["LactoseCrossbow.CrossbowBolt"           ]	=	{ AmmoType = "Projectile",	Emin =   200,	Emax =   350,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },

--- Historical Firearms Core
	["Base.Bullets9x18mm"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =   300,	Emax =   450,	Diameter =  9.27,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets303"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  3000,	Emax =  3600,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets30Cal"                      ]	=	{ AmmoType = "Bullet"    ,	Emin =  1200,	Emax =  1700,	Diameter =  7.62,	CanKill = true,	increaseHitTime = true, },

--- Historical Firearms Axis
	["Base.8mmKurtz"                          ]	=	{ AmmoType = "Bullet"    ,	Emin =  1700,	Emax =  2000,	Diameter =  8.22,	CanKill = true,	increaseHitTime = true, },
	["Base.8mmMauser"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =  3800,	Emax =  4000,	Diameter =  8.22,	CanKill = true,	increaseHitTime = true, },
	["Base.6x5Bullets"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  2200,	Emax =  2600,	Diameter =   6.8,	CanKill = true,	increaseHitTime = true, },
	["Base.9x25_Mauser_Bullets"               ]	=	{ AmmoType = "Bullet"    ,	Emin =   480,	Emax =   550,	Diameter =  9.01,	CanKill = true,	increaseHitTime = true, },
	["Base.65x50_Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2400,	Emax =  2800,	Diameter =  6.63,	CanKill = true,	increaseHitTime = true, },

--- Historical Firearms Arms of The 3rd Republic
	["Base.8mmLEBEL_Bullets"                  ]	=	{ AmmoType = "Bullet"    ,	Emin =  2800,	Emax =  3600,	Diameter =   8.3,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets32"                         ]	=	{ AmmoType = "Bullet"    ,	Emin =   170,	Emax =   300,	Diameter =  7.85,	CanKill = true,	increaseHitTime = true, },
	["Base.75x54_French_Bullets"              ]	=	{ AmmoType = "Bullet"    ,	Emin =  2600,	Emax =  3200,	Diameter =  7.84,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets8mmFO"                      ]	=	{ AmmoType = "Bullet"    ,	Emin =   170,	Emax =   300,	Diameter =  8.38,	CanKill = true,	increaseHitTime = true, },

--- Historical Firearms Eastern Bloc
	["Base.762x54Bullets"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2600,	Emax =  2800,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },

--- Z Life Stalker PSA Weapons Pack
	["Base.Bullets762Tokarev"                 ]	=	{ AmmoType = "Bullet"    ,	Emin =   500,	Emax =   700,	Diameter =   7.7,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets762Nagant"                  ]	=	{ AmmoType = "Bullet"    ,	Emin =   200,	Emax =   400,	Diameter =   7.8,	CanKill = true,	increaseHitTime = true, },
	["Base.23x75ShotgunShells"                ]	=	{ AmmoType = "Shotgun"   ,	Emin =  5000,	Emax =  5500,	Diameter =  23.0,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets939"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =   700,	Emax =  1000,	Diameter =  9.25,	CanKill = true,	increaseHitTime = true, },

--- Totally's Scavenged Firearms
	["Base.BulletsDirtyMagnum"                ]	=	{ AmmoType = "Bullet"    ,	Emin =   480,	Emax =   790,	Diameter =  9.06,	CanKill = true,	increaseHitTime = true, },
	["Base.BulletsDirty556"                   ]	=	{ AmmoType = "Bullet"    ,	Emin =  1070,	Emax =  1290,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.BulletsDirty308"                   ]	=	{ AmmoType = "Bullet"    ,	Emin =  1750,	Emax =  2660,	Diameter =  7.82,	CanKill = true,	increaseHitTime = true, },

--- Post-Soviet Armory
	["Base.Bullets545"                        ]	=	{ AmmoType = "Bullet"    ,	Emin =  1390,	Emax =  1890,	Diameter =   5.6,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets762AK"                      ]	=	{ AmmoType = "Bullet"    ,	Emin =  2300,	Emax =  2500,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets22LR"                       ]	=	{ AmmoType = "Bullet"    ,	Emin =   140,	Emax =   280,	Diameter =  5.56,	CanKill = true,	increaseHitTime = true, },
	["Base.Bullets762PKM"                     ]	=	{ AmmoType = "Bullet"    ,	Emin =  2600,	Emax =  2800,	Diameter =  7.92,	CanKill = true,	increaseHitTime = true, },

}

return CaliberData