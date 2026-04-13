# Dinghy Race Tracker

An iOS and Apple Watch app for tracking single-handed dinghy racing performance, with AI-powered post-race coaching.

## Overview

Built for competitive dinghy sailors racing classes such as Solo, ILCA 7, ILCA 6, RS Aero and Finn. The app tracks GPS speed, heading, tacks, jibes and lap times during a race, then provides an AI coaching debrief afterwards.

## Current Status

Phase 1 complete — full codebase built and pushed to GitHub. Next step: Xcode project setup and first build.

## Features Built

- GPS speed and heading tracking
- Tack and jibe logging
- Lap timing
- Race history and personal bests
- Stats overview
- AI post-race coaching debrief via Anthropic API
- Apple Watch companion app (speed display, start/stop tracking)
- Offline-first — records locally, syncs when back at club Wi-Fi
- Dual connectivity mode — offline sync or live cellular streaming

## Backlog

- Venue map selector (sailing location)
- Weather integration via Windy API
- Auto-stop tracking when AI detects sailing has stopped
- GPS route replay / race playback
- TV dashboard for spectators at the club
- Multi-user comparison and historical leaderboards
- Android and Garmin support

## File Structure
> ## Tech Stack
> 
> - Swift / SwiftUI
> - CoreLocation (GPS)
> - WatchConnectivity (Watch to iPhone sync)
> - Anthropic Claude API (AI coaching)
> - UserDefaults (local persistence)
> - iOS 15+ / watchOS 8+
> 
> ## API Key Setup
> 
> The Anthropic API key is never hardcoded. Add a Config.plist file to the Xcode project with the key AnthropicAPIKey and your key as the value. Add Config.plist to .gitignore so it is never pushed to GitHub.
> 
> ## Design Decisions
> 
> - Offline-first architecture — all data recorded locally on device
> - Two connectivity modes: offline sync and live cellular streaming
> - Watch app intentionally minimal — start and stop only, big speed display
> - Tacks and jibes logged automatically via GPS pattern detection (backlog)
> - AI debrief triggered manually after race to save API costs
> - No central backend for pilot phase — each sailor manages own data
> 
> ## Next Steps
> 
> 1. Xcode project setup
> 2. Add iPhone and Watch targets
> 3. Configure permissions
> 4. Add Config.plist for API key
> 5. First build and test on device
> 
> ## Contributing
> 
> Contributions and suggestions welcome. Open an issue or submit a pull request.
