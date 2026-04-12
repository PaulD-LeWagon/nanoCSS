# Changelog

> **Project:** [Project Name]
> All notable changes to this project are documented here.
> Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
> Versioning follows [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`
>
> - **MAJOR** — Breaking change (incompatible API change)
> - **MINOR** — New feature, backwards-compatible
> - **PATCH** — Bug fix, backwards-compatible

---

## [Unreleased]

> _Changes merged to main but not yet in a numbered release.
> Move entries to a versioned section at release time._

### Added
- [e.g. UC-003: User dashboard showing recent activity]

### Changed
- [e.g. UC-001: Password minimum length increased from 8 to 10 characters]

### Fixed
- [e.g. UC-002: Login form now clears password field on failed attempt]

---

## [0.2.0] — [YYYY-MM-DD] — Sprint 2

### Added
- [Feature or Use Case implemented]
- [Feature or Use Case implemented]

### Changed
- [Behaviour change — note previous and new behaviour]

### Fixed
- [Bug fixed — describe what was wrong and what is correct now]

### Security
- [Any security-relevant change — dependency update, vulnerability fix]

---

## [0.1.0] — [YYYY-MM-DD] — Sprint 1

### Added
- UC-001: User registration with email and password
- UC-002: User login with account lockout after 5 failed attempts
- Email confirmation sent on successful registration (mocked in test environment)

### Security
- Passwords hashed with bcrypt (cost factor 12)
- JWT stored in HttpOnly cookie — not accessible to JavaScript
- Rate limiting applied to all `/api/auth/*` endpoints

---

## Change Type Reference

| Type | Use When |
|---|---|
| **Added** | New feature, endpoint, component, or Use Case |
| **Changed** | Existing feature works differently — behaviour or API changed |
| **Deprecated** | Feature still works but will be removed in a future version |
| **Removed** | Feature or endpoint has been deleted |
| **Fixed** | Bug or incorrect behaviour corrected |
| **Security** | Vulnerability patched, dependency updated for security, auth change |
