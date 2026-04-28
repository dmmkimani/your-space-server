# YourSpace (Meeting Room Booking Application) - Backend

Backend service for a real-time meeting room booking system, responsible for replacing an email-based allocation process with a structured scheduling API.

**YourSpace Mobile Client:** https://github.com/dmmkimani/your-space-ui/

## Problem Context

Meeting room bookings at Swansea University were handled via email, creating:
- delayed confirmations
- lack of visibility into availability
- manual administrative overhead
- inability to act on “instant availability” (e.g. empty rooms observed in real time)

Room-mounted tablets partially mitigated visibility issues by displaying schedules for a subset of rooms, but lacked scalability across all spaces, remote access, and direct booking capability.

The system required a unified, actionable booking layer.

## System Overview

The backend acts as the system of record for booking operations, exposing an API for managing room availability and booking lifecycle transitions.

<p align="center">
  <img src="assets/images/system%20flowchart.PNG" alt="Booking Flowchart" width="600" />
  <br>
  <strong>Booking Flowchart</strong><br>
  <em>(click to view full size)</em>
</p>

## Core Design Decisions

#### 1. Slot-Based Scheduling Representation

Room availability is modelled as discrete time slots, enabling:
- deterministic conflict detection
- straightforward reservation checks
- simplified availability queries

**Trade-off:** Introduces rigidity in time representation, constraining bookings to predefined intervals, and increases write complexity as a single booking may span multiple slots.

#### 2. Dual-Entity Booking Consistency Model

Bookings are persisted in both:
- room schedules (availability perspective)
- user booking history (ownership perspective)

This trades strict normalisation for:
- faster read patterns
- simplified UI queries

**Trade-off:** Partial write failures can cause divergence between room availability and user history, requiring application-level compensation to restore consistency.

#### 3. Soft Deletion Strategy

Bookings are not fully removed from system history; instead they are flagged to:
- maintain auditability
- allow user-level history control
- preserve administrative traceability

**Trade-off:** Introduces additional storage overhead and increases query complexity, requiring consistent filtering to ensure logically deleted records do not surface in user-facing views.

#### 4. Firestore (NoSQL) as Persistence Layer

Firestore was selected over a relational database to prioritise:
- rapid iteration
- flexible schema evolution
- reduced initial modelling overhead

**Trade-off:** Relational integrity (joins, constraints) is replaced with application-level consistency enforcement.

## Impact on Booking Workflow

- **Replacement of an async, email-based booking process with a deterministic, request-driven scheduling system**, enabling immediate room allocation and eliminating manual coordination delays.
- **Server-authoritative source of truth for room availability**, with centrally validated state transitions ensuring consistency under concurrent access.
- **Reduced administrative overhead through automated booking lifecycle management**, shifting scheduling coordination from human operators to application logic.
- **Scalable extension of buildings and rooms without system redesign**, via schema-flexible modelling and runtime path-based resolution, minimising the marginal cost of domain expansion.
- **Preservation of historical booking state via soft-deletion**, supporting administrative traceability while maintaining clean user-facing data abstractions.

## Technology Stack

**Server:** Dart

**Database:** Firebase Firestore (NoSQL)

**Architecture:** REST API

