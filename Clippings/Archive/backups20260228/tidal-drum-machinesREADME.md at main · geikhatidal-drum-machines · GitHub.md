---
title: "tidal-drum-machines/README.md at main · geikha/tidal-drum-machines · GitHub"
source: "https://github.com/geikha/tidal-drum-machines/blob/main/README.md"
author:
  - "[[geikha]]"
published:
created: 2025-12-17
description:
tags:
  - "clippings"
---
## tidal-drum-machines

A huge collection of Drum Machines for SuperDirt and Tidal

See the full list of drum machines [here](https://github.com/geikha/tidal-drum-machines/blob/main/machines).

---

### Installation

```
// install this repository
Quarks.install("https://github.com/geikha/tidal-drum-machines.git");

// add this to your superdirt startup
~drumMachinesDir = Quarks.all.detect({ |x| x.name == "tidal-drum-machines" }).localPath;
~nameFunc  = { |x| x.basename.replace("-","")};
~dirt.loadSoundFiles(~drumMachinesDir +/+ "machines" +/+ "*" +/+ "*", namingFunction: ~nameFunc);
// Windows Users can use this line instead: (~drumMachinesDir +/+ "machines" +/+ "*").pathMatch.do({ |x| ~dirt.loadSoundFiles(x +/+ "*", namingFunction: ~nameFunc) });

// test in sclang
(type:\dirt, s: \rolandtr909cr, n: 0).play;
```

Thanks [Julian](https://github.com/telephon) for the installation script!

---

Run the custom SuperCollider bootup found in [tdm-sc-boot.scd](https://github.com/geikha/tidal-drum-machines/blob/main/tdm-sc-boot.scd), or add the necessary parts to your own bootup. Then run the haskell/tidal code found in [tdm-hs-setup.tidal](https://github.com/geikha/tidal-drum-machines/blob/main/tdm-hs-setup.tidal), or just copy and paste it from here:

```
let drumMachine name ps = stack 
                    (map (\ x -> 
                        (# s (name ++| (extractS "s" (x)))) $ x
                        ) ps)
    drumFrom name drum = s (name ++| drum)
    drumM = drumMachine
    drumF = drumFrom
```

### Examples

Here are some examples of how to use the drum machines:

#### drumMachines

```
d1 $ drumMachine "bossdr220" [
    s "[~perc]*2" # note 7
    ,s "bd:4(3,8)"
    ,s "~[cp,sd]"
    ,s "hh*8"
]
```

The drum machine can be pattern'd:

```
d1 $ drumMachine "<bossdr220 rolandtr808>" [
    s "[~perc]*2" # note 7
    ,s "bd:4(3,8)"
    ,s "~[cp,sd]"
    ,s "hh*8"
]
```

#### drumFrom

You can also just call one percussive element:

```
d1 $ drumFrom "linn9000" "bd*2"
```

This method could be useful for live performance:

```
do
 let dm = "linn9000"
 d1 $ drumFrom dm "bd*2"
```

---

| Drum | Abbreviation |
| --- | --- |
| Bass drum, Kick drum | bd |
| Snare drum | sd |
| Rimshot | rim |
| Clap | cp |
| Closed hi-hat | hh |
| Open hi-hat | oh |
| Crash | cr |
| Ride | rd |
| Shakers (and maracas, cabasas, etc) | sh |
| High tom | ht |
| Medium tom | mt |
| Low tom | lt |
| Cowbell | cb |
| Tambourine | tb |
| Other percussions | perc |
| Miscellaneous samples | misc |
| Effects | fx |