---
title: "tidalcycles/strudel"
source: "https://deepwiki.com/tidalcycles/strudel/1-overview"
author:
  - "[[DeepWiki]]"
published: 2025-08-21
created: 2025-12-23
description: "This document provides a comprehensive overview of the Strudel repository, a web-based live coding platform designed for creating and performing musical patterns in real-time. Strudel enables musician"
tags:
  - "clippings"
---
Menu

## Overview

Relevant source files
- [README.md](https://github.com/tidalcycles/strudel/blob/8a8ae9ac/README.md)

## Purpose and Scope

This document provides a comprehensive overview of the Strudel repository, a web-based live coding platform designed for creating and performing musical patterns in real-time. Strudel enables musicians and developers to write code that generates music directly in web browsers, with support for MIDI device integration and cross-platform desktop application bridging.

The overview covers the system's high-level architecture, core package structure, and development workflow. For detailed information about specific subsystems, see the Desktop Bridge System ([#2](https://deepwiki.com/tidalcycles/strudel/2-desktop-bridge-system)), MIDI Integration ([#3](https://deepwiki.com/tidalcycles/strudel/3-midi-integration)), Web Application ([#4](https://deepwiki.com/tidalcycles/strudel/4-web-application)), and Development and Deployment ([#5](https://deepwiki.com/tidalcycles/strudel/5-development-and-deployment)) sections.

## System Architecture

Strudel operates as a modular web platform with distinct layers for user interaction, core functionality, and external system integration. The platform serves multiple deployment targets including the main web application at strudel.cc and supporting documentation systems.

### High-Level System Structure


```
External_TargetsBuild_SystemCore_PackagesWeb_Platformstrudel.ccDocumentation_Site@strudel/react@strudel/midi@strudel/desktop-bridgevite.config.jspackage.jsonWeb_BrowsersMIDI_HardwareDesktop_Applications
```

Sources: [README.md 1-9](https://github.com/tidalcycles/strudel/blob/8a8ae9ac/README.md#L1-L9)

## Core Component Architecture

The system's modular design separates concerns across specialized packages, each handling specific aspects of the live coding environment. The architecture enables seamless integration between web-based pattern creation and external audio/MIDI ecosystems.


### Package Dependencies and Code Mapping

```
Build_ArtifactsIntegration_LayerFrontend_LayerReact_ComponentsWeb_InterfaceStrudel_REPLDesktop_BridgeMIDI_HandlerWeb_MIDI_APIdist/public/
```

Sources: [README.md 1-9](https://github.com/tidalcycles/strudel/blob/8a8ae9ac/README.md#L1-L9)

## Platform Characteristics

Strudel functions as a browser-based development environment that bridges traditional live coding workflows with modern web technologies. The platform supports real-time pattern manipulation, MIDI device communication, and integration with external desktop audio applications.

| Component | Purpose | Target Environment |
| --- | --- | --- |
| Web Application | Primary live coding interface | Web browsers |
| Desktop Bridge | Cross-platform communication | Desktop applications |
| MIDI Integration | Hardware device connectivity | MIDI controllers/devices |
| React Components | User interface elements | Web frontend |
| Documentation System | Technical reference | Static web hosting |

The system architecture prioritizes modularity, enabling developers to integrate Strudel components into external projects while maintaining a cohesive user experience for live coding sessions.

## Development Context

Development activity has migrated from the GitHub repository to a new primary location at codeberg.org/uzu/strudel, as indicated in the repository README. This migration represents an evolution in the project's development workflow and hosting strategy.

### Repository Status

```
Development_Movedgithub.com/tidalcycles/strudelcodeberg.org/uzu/strudelstrudel.cc
```

The current repository serves as a reference point and deployment source for the live web application, while active development continues on the Codeberg platform. Users and contributors should reference the new repository location for the most current development activity.

Sources: [README.md 6-8](https://github.com/tidalcycles/strudel/blob/8a8ae9ac/README.md#L6-L8)