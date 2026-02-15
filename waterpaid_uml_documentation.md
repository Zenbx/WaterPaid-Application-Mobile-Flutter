# WaterPaid — Documentation UML Complète

Ce document fournit tous les éléments nécessaires pour dessiner les diagrammes UML du système WaterPaid : cas d'utilisation, diagrammes de classes, diagrammes de séquence (workflows), et diagrammes d'état.

---

## 1. Acteurs du Système

| Acteur | Description |
|--------|-------------|
| **Utilisateur (User)** | Client final qui gère ses compteurs d'eau et effectue des recharges |
| **Administrateur (Admin)** | Gestionnaire qui crée les compteurs, supervise les utilisateurs et génère des rapports |
| **Système MQTT** | Broker IoT qui communique avec les compteurs physiques (ouverture/fermeture vanne) |
| **Device (Compteur physique)** | Hardware IoT LoRaWAN qui envoie les données de consommation et reçoit les commandes |

---

## 2. Diagramme d'Architecture Globale

Le diagramme d'architecture globale offre une vision macroscopique de l'écosystème WaterPaid. Il illustre la convergence entre les technologies mobiles (Flutter), les services cloud (FastAPI/Supabase), et le monde de l'Internet des Objets (IoT) via le réseau LoRaWAN. On y voit comment les flux de données circulent depuis le capteur physique jusqu'à l'utilisateur final, tout en intégrant des services tiers essentiels comme les passerelles de paiement (PayUnit). C'est la pierre angulaire de la compréhension système du projet.

```plantuml
@startuml WaterPaid_Global_Architecture
!define RECTANGLE rectangle

skinparam monochrome false
skinparam packageStyle rectangle

actor "Utilisateur" as User
actor "Administrateur" as Admin

RECTANGLE "Écosystème WaterPaid" {
  package "Terminal Mobile" {
    [App Mobile (Flutter)] as FlutterApp
  }

  package "Infrastructure Cloud (Ouvrage)" {
    [API Backend (FastAPI)] as API
    database "PostgreSQL (Supabase)" as DB
    [Broker MQTT Client] as MQTT
  }

  package "Infrastructure IoT LoRaWAN" {
    [ChirpStack (Network Server)] as LNS
    [Compteur Intelligent] as MeterHardware
  }
}

package "Services Externes" {
  [Passerelle de Paiement (PayUnit)] as Payment
}

' --- Connexions ---
User --> FlutterApp : Interaction UI
Admin --> API : Administration technique
FlutterApp <--> API : REST / WebSockets
API <--> DB : Persistance (SQLAlchemy)
API <--> Payment : Validation recharges
API <--> MQTT : Flux de données IoT
MQTT <--> LNS : Interfaçage LoRa
LNS <--> MeterHardware : Réseau LoRaWAN (Uplink/Downlink)

@enduml
```

---

## 3. Diagramme de Cas d'Utilisation

### 3.1 Cas d'Utilisation — Utilisateur (User)

| ID | Cas d'Utilisation | Description | Préconditions | Postconditions |
|----|-------------------|-------------|---------------|----------------|
| UC-U01 | **S'inscrire** | Créer un compte utilisateur avec téléphone, pseudo et mot de passe | Aucune | Compte créé, token JWT généré |
| UC-U02 | **Se connecter** | Authentification par téléphone + mot de passe | Compte existant | Token JWT valide, redirection vers Dashboard |
| UC-U03 | **Se déconnecter** | Terminer la session | Connecté | Token supprimé du stockage local |
| UC-U04 | **Consulter le Dashboard** | Voir les statistiques : solde, total dépensé, compteurs actifs, recharges récentes | Connecté | Dashboard affiché |
| UC-U05 | **Lier un compteur** | Scanner un QR code ou entrer un token pour associer un compteur à son compte | Connecté, compteur non attribué | Compteur attribué à l'utilisateur |
| UC-U06 | **Délier un compteur** | Retirer un compteur de son compte | Connecté, compteur attribué à l'utilisateur | Compteur libéré |
| UC-U07 | **Effectuer une recharge** | Payer pour recharger un compteur (OM, MOMO, CASH) | Connecté, compteur lié | Recharge créée (PENDING), notification MQTT au device si SUCCEEDED |
| UC-U08 | **Consulter l'historique** | Voir toutes ses recharges passées | Connecté | Liste des recharges affichée |
| UC-U09 | **Voir son profil** | Consulter ses informations personnelles | Connecté | Profil affiché |

### 3.2 Cas d'Utilisation — Administrateur (Admin)

| ID | Cas d'Utilisation | Description | Préconditions | Postconditions |
|----|-------------------|-------------|---------------|----------------|
| UC-A01 | **S'inscrire (Admin)** | Créer un compte administrateur | Aucune | Compte admin créé, token JWT généré |
| UC-A02 | **Se connecter** | Authentification admin | Compte existant | Token JWT valide, redirection vers Admin Dashboard |
| UC-A03 | **Consulter le Dashboard Admin** | Vue globale : compteurs, utilisateurs, activité récente | Connecté (admin) | Statistiques affichées |
| UC-A04 | **Créer un compteur** | Enregistrer un nouveau compteur virtuel (serial_id, device_id optionnel) | Connecté (admin) | Compteur créé avec token unique |
| UC-A05 | **Lister les compteurs** | Voir tous les compteurs gérés par l'admin | Connecté (admin) | Liste affichée |
| UC-A06 | **Voir détails d'un compteur** | Infos complètes : état, token, utilisateur assigné, device lié | Connecté (admin) | Détails affichés |
| UC-A07 | **Modifier un compteur** | Changer l'état (ACTIVE/INACTIVE/MAINTENANCE), assigner un utilisateur | Connecté (admin), compteur existant | Compteur mis à jour |
| UC-A08 | **Supprimer un compteur** | Retirer définitivement un compteur | Connecté (admin), compteur existant | Compteur supprimé avec ses recharges |
| UC-A09 | **Générer un token** | Créer un nouveau token d'appairage pour un compteur | Connecté (admin), compteur existant | Nouveau token UUID généré |
| UC-A10 | **Lier un device** | Associer un compteur physique (LoRaWAN) à un compteur logique | Connecté (admin), device existant | Device lié au compteur |
| UC-A11 | **Recharger manuellement** | Effectuer une recharge CASH immédiatement validée (SUCCEEDED) | Connecté (admin), compteur attribué | Recharge créée + notification MQTT au device |
| UC-A12 | **Lister les utilisateurs** | Voir les utilisateurs assignés aux compteurs de l'admin | Connecté (admin) | Liste affichée |
| UC-A13 | **Consulter l'historique** | Voir l'historique de recharges par utilisateur ou par compteur | Connecté (admin) | Historique affiché |
| UC-A14 | **Générer un rapport** | Créer un rapport CSV ou PDF sur une période donnée | Connecté (admin) | Rapport créé |
| UC-A15 | **Lister les rapports** | Voir tous les rapports générés | Connecté (admin) | Liste affichée |
| UC-A16 | **Mettre à jour statut recharge** | Changer le statut d'une recharge (PENDING → SUCCEEDED/FAILED) | Connecté (admin) | Recharge mise à jour, notification MQTT si SUCCEEDED |
| UC-A17 | **Délier un utilisateur** | Retirer un utilisateur d'un compteur (l'utilisateur ne pourra plus utiliser ce compteur) | Connecté (admin), compteur attribué | Compteur libéré (user_id=null, attributed=false) |

### 3.3 Diagramme PlantUML — Cas d'Utilisation

Ce diagramme de cas d’utilisation synthétise les fonctionnalités offertes par la plateforme WaterPaid. Il met en évidence la séparation des responsabilités entre l'utilisateur final (gestion de sa consommation et paiement) et l'administrateur technique (gestion de flotte IoT et supervision). L'inclusion du système MQTT souligne l'importance de l'interaction physique avec les compteurs, qui est le cœur de métier du projet.

```plantuml
@startuml WaterPaid_UseCases
left to right direction
skinparam packageStyle rectangle

actor "Utilisateur" as User
actor "Administrateur" as Admin
actor "Système MQTT" as MQTT

rectangle "WaterPaid" {
  ' --- Auth (commun) ---
  usecase "S'inscrire" as UC_Signup
  usecase "Se connecter" as UC_Login
  usecase "Se déconnecter" as UC_Logout

  ' --- User ---
  usecase "Consulter Dashboard" as UC_Dashboard
  usecase "Lier un compteur" as UC_LinkMeter
  usecase "Délier un compteur" as UC_UnlinkMeter
  usecase "Effectuer une recharge" as UC_Refill
  usecase "Consulter l'historique" as UC_History
  usecase "Voir son profil" as UC_Profile

  ' --- Admin ---
  usecase "Dashboard Admin" as UC_AdminDash
  usecase "Créer un compteur" as UC_CreateMeter
  usecase "Lister les compteurs" as UC_ListMeters
  usecase "Voir détails compteur" as UC_MeterDetail
  usecase "Modifier un compteur" as UC_UpdateMeter
  usecase "Supprimer un compteur" as UC_DeleteMeter
  usecase "Générer un token" as UC_GenToken
  usecase "Lier un device" as UC_LinkDevice
  usecase "Recharger manuellement" as UC_AdminRefill
  usecase "Lister les utilisateurs" as UC_ListUsers
  usecase "Historique admin" as UC_AdminHistory
  usecase "Générer un rapport" as UC_CreateReport
  usecase "Lister les rapports" as UC_ListReports
  usecase "MAJ statut recharge" as UC_UpdateRefill
  usecase "Délier un utilisateur" as UC_UnlinkUser
  usecase "Notifier le device" as UC_NotifyDevice
}

User --> UC_Signup
User --> UC_Login
User --> UC_Logout
User --> UC_Dashboard
User --> UC_LinkMeter
User --> UC_UnlinkMeter
User --> UC_Refill
User --> UC_History
User --> UC_Profile

Admin --> UC_Signup
Admin --> UC_Login
Admin --> UC_Logout
Admin --> UC_AdminDash
Admin --> UC_CreateMeter
Admin --> UC_ListMeters
Admin --> UC_MeterDetail
Admin --> UC_UpdateMeter
Admin --> UC_DeleteMeter
Admin --> UC_GenToken
Admin --> UC_LinkDevice
Admin --> UC_AdminRefill
Admin --> UC_ListUsers
Admin --> UC_AdminHistory
Admin --> UC_CreateReport
Admin --> UC_ListReports
Admin --> UC_UpdateRefill
Admin --> UC_UnlinkUser

UC_Refill ..> UC_NotifyDevice : <<include>>
UC_AdminRefill ..> UC_NotifyDevice : <<include>>
UC_UpdateRefill ..> UC_NotifyDevice : <<include>>
UC_NotifyDevice --> MQTT

@enduml
```

---

## 4. Diagramme de Classes

### 4.1 Entités et Attributs

Le diagramme de classes suivant modélise le domaine métier de WaterPaid. Il reflète la structure de données persistée en base de données PostgreSQL (via Supabase). On y retrouve les concepts clés de l'application : la gestion des utilisateurs, les compteurs logiques (`Meter`) liés aux dispositifs physiques (`Device`), ainsi que la traçabilité des recharges financières. Les relations de cardinalité (1-1 ou 1-*) garantissent l'intégrité référentielle du système.

```plantuml
@startuml WaterPaid_ClassDiagram
skinparam classAttributeIconSize 0

enum MeterStateEnum {
  INACTIVE
  ACTIVE
  MAINTENANCE
}

enum RefillMethodEnum {
  OM
  MOMO
  CASH
}

enum RefillStateEnum {
  SUCCEEDED
  PENDING
  FAILED
}

enum ReportFormatEnum {
  CSV
  PDF
}

class User {
  + user_id : UUID <<PK>>
  + user_phone : Text <<UNIQUE>>
  + user_password : Text
  + user_pseudo : Text
  + user_email : Text <<UNIQUE>>
  + created_at : Timestamp
  + updated_at : Timestamp
}

class Admin {
  + admin_id : UUID <<PK>>
  + admin_phone : Text <<UNIQUE>>
  + admin_password : Text
  + admin_pseudo : Text
  + admin_email : Text <<UNIQUE>>
  + created_at : Timestamp
  + updated_at : Timestamp
}

class Meter {
  + meter_id : UUID <<PK>>
  + user_id : UUID <<FK → User>>
  + admin_id : UUID <<FK → Admin>>
  + token : UUID <<UNIQUE>>
  + attributed : Boolean
  + serial_id : Text <<UNIQUE>>
  + meter_state : MeterStateEnum
  + registered_at : Timestamp
  + device_id : Text <<UNIQUE>>
  --
  + isActive() : Boolean
  + isLinked() : Boolean
}

class Refill {
  + refill_id : UUID <<PK>>
  + user_id : UUID <<FK → User>>
  + meter_id : UUID <<FK → Meter>>
  + refill_phone : Text
  + refill_method : RefillMethodEnum
  + refill_state : RefillStateEnum
  + price : Real
  + volume : Real
  + created_at : Timestamp
  + updated_at : Timestamp
  + receiver_phone : Text
}

class Report {
  + report_id : UUID <<PK>>
  + admin_id : UUID <<FK → Admin>>
  + started_at : Timestamp
  + ended_at : Timestamp
  + format : ReportFormatEnum
  + created_at : Timestamp
}

class Device {
  + dev_eui : Text <<PK>>
  + meter_id : UUID <<FK → Meter>>
  + battery_level : Integer
  + valve_state : Text
  + last_volume : Float
  + rssi : Float
  + last_uplink : Timestamp
  + created_at : Timestamp
}

class Rate {
  + rate_id : UUID <<PK>>
  + admin_id : UUID <<FK → Admin>>
  + price : Real
  + volume : Real
  + created_at : Timestamp
  + updated_at : Timestamp
}

' === Relations ===
User "1" -- "0..1" Meter : possède >
Admin "1" -- "0..*" Meter : gère >
User "1" -- "0..*" Refill : effectue >
Meter "1" -- "0..*" Refill : concerne >
Admin "1" -- "0..*" Report : génère >
Admin "1" -- "0..*" Rate : définit >
Device "0..1" -- "0..1" Meter : lié à >

Meter ..> MeterStateEnum
Refill ..> RefillMethodEnum
Refill ..> RefillStateEnum
Report ..> ReportFormatEnum

@enduml
```

### 4.2 Résumé des Relations

| Relation | Cardinalité | Description |
|----------|-------------|-------------|
| User ↔ Meter | 1 — 0..1 | Un User possède au maximum un compteur (relation `uselist=False`) |
| Admin ↔ Meter | 1 — 0..* | Un Admin gère plusieurs compteurs |
| User ↔ Refill | 1 — 0..* | Un User effectue plusieurs recharges (cascade delete) |
| Meter ↔ Refill | 1 — 0..* | Un Meter est concerné par plusieurs recharges (cascade delete) |
| Admin ↔ Report | 1 — 0..* | Un Admin génère plusieurs rapports (cascade delete) |
| Admin ↔ Rate | 1 — 0..* | Un Admin définit plusieurs tarifs (cascade delete) |
| Device ↔ Meter | 0..1 — 0..1 | Un Device physique est lié à un Meter logique |

---

## 5. Diagramme de Classes — Services (Couche Métier)

Au-delà des données, ce diagramme illustre l'organisation de la logique métier (Business Logic) au sein du backend FastAPI. L'architecture repose sur des services spécialisés qui orchestrent les opérations complexes, comme la validation des paiements ou l'envoi de commandes LoRaWAN via MQTT. Cette séparation des préoccupations (SoC) permet une maintenance aisée et une évolutivité du système.

```plantuml
@startuml WaterPaid_Services
skinparam classAttributeIconSize 0

class AuthService {
  - db : Session
  - user_repo : UserRepository
  - admin_repo : AdminRepository
  --
  + signup_user(request: SignupRequest) : Dict
  + signup_admin(request: SignupRequest) : Dict
  + login(request: LoginRequest) : Dict
  - _generate_token_response(account, type) : Dict
}

class UserService {
  - db : Session
  - user_repo : UserRepository
  - meter_repo : MeterRepository
  - refill_repo : RefillRepository
  - mqtt_client : MQTTClient
  --
  + get_dashboard(user_id, current_user) : Dict
  + create_refill(meter_id, refill_data, current_user) : Dict
  + get_history(user_id, current_user) : List
  + assign_meter(request, current_user) : Dict
  + unassign_meter(meter_id, current_user) : void
}

class AdminService {
  - db : Session
  - admin_repo : AdminRepository
  - user_repo : UserRepository
  - meter_repo : MeterRepository
  - refill_repo : RefillRepository
  - report_repo : ReportRepository
  - device_repo : DeviceRepository
  - mqtt_service : MQTTService
  --
  + get_users(admin_id) : List
  + get_meters(admin_id) : List
  + create_meter(meter_data, admin_id) : Dict
  + get_meter(meter_id, admin_id) : Dict
  + update_meter(meter_id, update, admin_id) : Dict
  + delete_meter(meter_id, admin_id) : void
  + create_refill(meter_id, data, admin_id) : Dict
  + get_refill_history(id, admin_id) : List
  + get_reports(admin_id) : List
  + create_report(data, admin_id) : Dict
  + generate_meter_token(meter_id, admin_id) : Dict
  + update_refill(refill_id, status, admin_id) : Dict
  + unlink_user(meter_id, admin_id) : Dict
  + link_device(meter_id, device_id, admin_id) : Dict
}

class MQTTService {
  - db : Session
  - mqtt_client : MQTTClient
  - device_repo : DeviceRepository
  - meter_repo : MeterRepository
  --
  + process_device_data(dev_eui, payload) : void
  + update_device_status(dev_eui, payload) : void
  + send_valve_command(dev_eui, action) : Boolean
  + notify_refill_succeeded(meter_id, refill_id, volume) : Boolean
  - _check_credit(meter_id, volume) : Dict
  - _broadcast_to_websocket(meter_id, data) : void
}

AdminService --> MQTTService : utilise
UserService --> MQTTService : utilise (indirectement)
AuthService --> UserService : appelle login() après signup
@enduml
```

---

## 6. Workflows — Diagrammes de Séquence

### 6.1 Inscription et Connexion (User & Admin)

Ce workflow détaille la sécurisation des accès. Il met en scène l'échange de jetons JWT (JSON Web Tokens) signés en HS256, assurant que seules les requêtes authentifiées peuvent interagir avec les ressources sensibles du système.

```plantuml
@startuml WF_Auth
actor "Client" as C
participant "API /auth" as API
participant "AuthService" as AS
database "DB (User/Admin)" as DB

== Inscription ==
C -> API : POST /auth/signup {phone, pseudo, password, user_type}
API -> AS : signup_user() ou signup_admin()
AS -> DB : Vérifier téléphone unique
AS -> DB : Créer User ou Admin
AS -> AS : Générer JWT {sub: id, type: "user"|"admin"}
AS --> C : {access_token, user: {user_id, user_type, ...}}

== Connexion ==
C -> API : POST /auth/login {phone, password}
API -> AS : login()
AS -> DB : Chercher dans User (par phone)
alt Trouvé dans User
  AS -> AS : verify_password()
  AS --> C : {access_token, user: {user_type: "user"}}
else Non trouvé → chercher Admin
  AS -> DB : Chercher dans Admin (par phone)
  AS -> AS : verify_password()
  AS --> C : {access_token, user: {user_type: "admin"}}
end
@enduml
```

### 6.2 Workflow User — Lier un compteur

```plantuml
@startuml WF_LinkMeter
actor "User" as U
participant "API /u/meter" as API
participant "UserService" as US
database "DB" as DB

U -> API : POST /u/meter {token}
API -> US : assign_meter(request, current_user)
US -> DB : Chercher Meter par token
alt Meter non trouvé
  US --> U : 404 "Aucun compteur avec ce token"
else Meter déjà attribué
  US --> U : 400 "Compteur déjà attribué"
else Meter disponible
  US -> DB : metre.user_id = current_user.id
  US -> DB : meter.attributed = true
  US --> U : 200 {meter_id, token, attributed: true}
end
@enduml
```

### 6.3 Workflow User — Effectuer une recharge

C'est le processus critique du système. Ce diagramme de séquence illustre la chaîne complète : du déclenchement du paiement sur l'application mobile à l'ouverture physique de la vanne d'eau. Il met en évidence l'interaction asynchrone entre le backend et le réseau LoRaWAN via le protocole MQTT.

```plantuml
@startuml WF_Refill
actor "User" as U
participant "API /u/refill" as API
participant "UserService" as US
participant "MQTTService" as MQTT
participant "Device" as D
database "DB" as DB

U -> API : POST /u/refill/{meter_id} {price, volume, method}
API -> US : create_refill(meter_id, data, current_user)
US -> DB : Vérifier Meter existe et appartient à User
US -> DB : Créer Refill (état: PENDING)
US --> U : 201 {refill_id, refill_state: "PENDING"}

note over US : Le paiement est traité (OM/MOMO/CASH)
note over US : Quand le paiement réussit...

US -> DB : Refill.refill_state = SUCCEEDED
US -> MQTT : notify_refill_succeeded(meter_id, refill_id, volume)
MQTT -> DB : Chercher Device lié au Meter
MQTT -> D : Publish MQTT {action: "REFILL_SUCCEEDED", volume}
D -> D : Ouvrir la vanne

@enduml
```

### 6.4 Workflow Admin — Créer un compteur

```plantuml
@startuml WF_CreateMeter
actor "Admin" as A
participant "API /admin/meters" as API
participant "AdminService" as AS
database "DB" as DB

A -> API : POST /admin/meters {serial_id, device_id?}
API -> AS : create_meter(data, admin_id)
AS -> DB : Créer Meter {meter_id: UUID, admin_id, serial_id, token: UUID, attributed: false}
AS --> A : 201 {meter_id, token, serial_id, meter_state: "INACTIVE"}
@enduml
```

### 6.5 Workflow Admin — Recharge manuelle

```plantuml
@startuml WF_AdminRefill
actor "Admin" as A
participant "API /admin/refill-meters" as API
participant "AdminService" as AS
participant "MQTTService" as MQTT
participant "Device" as D
database "DB" as DB

A -> API : POST /admin/refill-meters/{meter_id} {price, volume}
API -> AS : create_refill(meter_id, data, admin_id)
AS -> DB : Vérifier Meter appartient à Admin
AS -> DB : Vérifier Meter est attribué
AS -> DB : Créer Refill (method: CASH, state: SUCCEEDED)
AS -> MQTT : notify_refill_succeeded(meter_id, refill_id, volume)
MQTT -> DB : Chercher Device lié au Meter
alt Device trouvé
  MQTT -> D : Publish MQTT {action: "REFILL_SUCCEEDED", volume}
  D -> D : Ouvrir la vanne
  MQTT --> AS : true
else Aucun device
  MQTT --> AS : false (log warning)
end
AS --> A : 201 {refill_id, refill_state: "SUCCEEDED"}
@enduml
```

### 6.6 Workflow Admin — Lier un device physique

```plantuml
@startuml WF_LinkDevice
actor "Admin" as A
participant "API /admin/meters" as API
participant "AdminService" as AS
database "DB" as DB

A -> API : POST /admin/meters/{meter_id}/link-device?device_id=xxx
API -> AS : link_device(meter_id, device_id, admin_id)
AS -> DB : Vérifier Meter appartient à Admin
AS -> DB : Vérifier Device existe (mqtt_devices)
AS -> DB : device.meter_id = meter.meter_id
AS --> A : 200 {device_id, meter_id, battery_level, valve_state}
@enduml
```

### 6.7 Workflow Admin — Délier un utilisateur

```plantuml
@startuml WF_UnlinkUser
actor "Admin" as A
participant "API /admin/meters" as API
participant "AdminService" as AS
database "DB" as DB

A -> API : POST /admin/meters/{meter_id}/unlink-user
API -> AS : unlink_user(meter_id, admin_id)
AS -> DB : Vérifier Meter appartient à Admin
alt Meter non trouvé
  AS --> A : 404 "Compteur non trouvé"
else Meter non attribué
  AS --> A : 400 "Ce compteur n'est pas attribué"
else Meter attribué
  AS -> DB : meter.user_id = NULL
  AS -> DB : meter.attributed = false
  AS --> A : 200 {meter_id, user_id: null, attributed: false}
end
@enduml
```

### 6.8 Workflow MQTT — Réception données device

```plantuml
@startuml WF_MQTT
participant "Device IoT" as D
participant "Broker MQTT" as B
participant "MQTTService" as MS
participant "WebSocket" as WS
database "DB" as DB

D -> B : Publish waterpaid/{dev_eui}/data {litres, battery, valve, rssi}
B -> MS : on_message()
MS -> DB : Mettre à jour Device (battery, valve, volume, rssi)
MS -> WS : Broadcaster aux clients connectés
MS -> DB : Vérifier crédit (somme recharges - volume consommé)
alt Crédit insuffisant ET vanne ouverte
  MS -> B : Publish waterpaid/{dev_eui}/cmd {action: "CLOSE_VALVE"}
  B -> D : Fermer la vanne
else Crédit rétabli ET vanne fermée
  MS -> B : Publish waterpaid/{dev_eui}/cmd {action: "OPEN_VALVE"}
  B -> D : Ouvrir la vanne
end
@enduml
```

---

## 7. Diagramme d'États — Cycle de Vie du Compteur (Meter)

Ce diagramme modélise la vie administrative et opérationnelle d'un compteur IoT au sein du système. Il est crucial pour garantir l'intégrité du parc matériel.

### Description des États
*   **INACTIVE** : État initial lors de l'enregistrement du numéro de série. Le compteur existe dans la base mais est "dormant". Il ne peut pas être attribué à un client.
*   **ACTIVE** : Le compteur est en service. Il écoute le réseau LoRaWAN et peut être lié à un utilisateur. C'est le seul état permettant la consommation d'eau.
    *   *Sous-état : Non Attribué* — Le compteur est libre, en attente d'un QR Scan.
    *   *Sous-état : Attribué* — Le compteur est lié à un `user_id`.
*   **MAINTENANCE** : État transitoire pour les interventions techniques (changement de batterie, réparation). Le compteur est déconnecté logiquement des utilisateurs pour éviter les fausses alertes.

### Description des Transitions
Le passage de `INACTIVE` à `ACTIVE` est une action manuelle de l'administrateur (Provisioning). Inversement, la mise en `MAINTENANCE` est une décision de gestion. L'attribution (`Attributed`) est déclenchée par l'utilisateur final via l'application mobile (Scan QR), mais n'est possible que si le compteur est d'abord `ACTIVE`.

```plantuml
@startuml State_Meter
state "INACTIVE" as INACTIVE : En stock / Pas encore déployé
state "ACTIVE" as ACTIVE : En service chez le client
state "MAINTENANCE" as MAINTENANCE : Intervention technique en cours

[*] --> INACTIVE : Création (Inv stock)
INACTIVE --> ACTIVE : Activation (Mise en service)
ACTIVE --> MAINTENANCE : Panne signalée
MAINTENANCE --> ACTIVE : Réparation terminée
ACTIVE --> INACTIVE : Retrait du parc
INACTIVE --> [*] : Rebut / Destruction

state ACTIVE {
  state "Non Attribué" as Free
  state "Attribué (Linked)" as Linked
  
  [*] --> Free
  Free --> Linked : Scan QR / Saisie Token
  Linked --> Free : Délier (Déménagement)
}
@enduml
```

## 8. Diagramme d'États — Cycle de Vie d'une Recharge (Refill)

Ce diagramme illustre le processus transactionnel financier. Il sécurise le chiffre d'affaires en garantissant qu'aucune goutte d'eau n'est distribuée sans une validation bancaire préalable.

### Description des États
*   **PENDING (En attente)** : La transaction est initiée par l'utilisateur. Une référence de paiement est créée, mais l'argent n'est pas encore confirmé.
*   **SUCCEEDED (Succès)** : La passerelle de paiement (PayUnit) ou l'administrateur a confirmé la réception des fonds. C'est l'état final positif.
*   **FAILED (Échec)** : La transaction a été annulée, refusée par la banque ou a expiré. C'est un état final négatif.

### Description des Transitions et Effets de Bord
*   **Confirmation (Pending → Succeeded)** : Cette transition est critique. Elle déclenche automatiquement un événement système (`Event Hook`) qui :
    1.  Crédite le solde virtuel du compteur.
    2.  Envoie un ordre MQTT `OPEN_VALVE` immédiat au compteur physique via le réseau LoRaWAN.
*   **Échec (Pending → Failed)** : Aucune action sur le matériel. L'utilisateur est notifié et doit recommencer.

```plantuml
@startuml State_Refill
hide empty description

state "PENDING" as PENDING : Attente retour Mobile Money
state "SUCCEEDED" as SUCCEEDED : Paiement validé\n(Crédit ajouté + Vanne ouverte)
state "FAILED" as FAILED : Solde insuffisant / Timeout

[*] --> PENDING : Initier achat (App)
[*] --> SUCCEEDED : Paiement CASH (Guichet)

PENDING --> SUCCEEDED : Webhook PayUnit (200 OK)
PENDING --> FAILED : Erreur / Annulation

SUCCEEDED --> [*] : Fin de transaction
FAILED --> [*] : Fin de transaction
@enduml
```

---

## 9. Résumé des Endpoints API

### 9.1 Public & Auth
| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| GET | `/` | Racine de l'API (Statut) |
| GET | `/health` | Test de santé (DB & MQTT) |
| POST | `/auth/signup` | Inscription Utilisateur/Admin |
| POST | `/auth/login` | Connexion (Retourne JWT) |

### 9.2 Utilisateur (Prefix: `/u`)
| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| GET | `/u/dashboard/{id}` | Stats dashboard (solde, conso) |
| GET | `/u/history/{id}` | Historique des recharges |
| PUT | `/u/me/` | Modifier profil (pseudo, tel) |
| PUT | `/u/me/change-password` | Changer mot de passe |
| POST | `/u/meter` | Assigner un compteur (via token) |
| DELETE | `/u/meter/{id}` | Dissocier un compteur |
| POST | `/u/refill/{id}` | Initier une recharge |

### 9.3 Administrateur (Prefix: `/a`)
| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| GET | `/a/` | Statistiques globales dashboard |
| GET | `/a/users` | Liste des clients gérés |
| GET | `/a/meters` | Liste des compteurs gérés |
| POST | `/a/meters` | Créer un nouveau compteur |
| GET | `/a/meters/{id}` | Détails techniques d'un compteur |
| PUT | `/a/meters/{id}` | Modifier un compteur |
| DELETE | `/a/meters/{id}` | Supprimer un compteur |
| POST | `/a/meters/{id}/generate-token` | Régénérer token d'appairage |
| POST | `/a/meters/{id}/link-device` | Lier device physique (LoRaWAN) |
| POST | `/a/meters/{id}/unlink-user` | Délier un utilisateur du compteur |
| POST | `/a/refill-meters/{id}` | Recharge manuelle (CASH) |
| PUT | `/a/refill-meters/{id}` | Modifier statut recharge |
| GET | `/a/histories/{id}` | Historique recharges (filtre id) |
| GET | `/a/reports` | Liste des rapports générés |
| POST | `/a/reports` | Générer un rapport CSV |
| PUT | `/a/me/` | Modifier profil admin |
| PUT | `/a/me/change-password` | Changer mot de passe admin |

### 9.4 Télémétrie & IoT (Prefix: `/api`)
| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| POST | `/api/devices/register` | Enregistrer un device IoT |
| GET | `/api/devices/` | Lister tous les devices |
| GET | `/api/devices/{eui}/status` | Statut + dernière télémétrie |
| GET | `/api/devices/{eui}/history` | Historique complet télémétrie |
| GET | `/api/devices/{eui}/battery` | Historique niveau batterie |
| POST | `/api/lorawan/uplink` | Webhook Uplink ChirpStack |
| POST | `/api/lorawan/join` | Webhook Join Event |

### 9.5 Webhooks & Temps Réel
| Méthode | Endpoint | Description |
| :--- | :--- | :--- |
| WS | `/ws/devices/{meter_id}` | Stream temps réel (volume, vanne) |
| POST | `/webhook/payment/success` | Webhook succès paiement |
| POST | `/webhook/payment/failed` | Webhook échec paiement |
| GET | `/docs/websocket` | Documentation interactive WS |

---

## 10. Descriptions Détaillées des Cas d'Utilisation

### 10.1 Cas d'Utilisation — Utilisateur (User)

#### UC-U01 : S'inscrire
- **Acteurs** : Utilisateur
- **Pré-conditions** : Aucune
- **Post-conditions** : Compte créé, l'utilisateur est connecté.
- **Scénario Nominal** :
    1. L'utilisateur saisit son numéro de téléphone, pseudo et mot de passe.
    2. Le système vérifie l'unicité du numéro de téléphone.
    3. Le système crypte le mot de passe et crée le compte.
    4. Le système renvoie un token JWT.
- **Scénarios Alternatifs** :
    - *Téléphone déjà utilisé* : Le système affiche une erreur d'unicité.
    - *Données invalides* : Le système demande de corriger les champs.

#### UC-U02 : Se connecter
- **Acteurs** : Utilisateur (ou Admin)
- **Pré-conditions** : Compte existant.
- **Post-conditions** : Utilisateur authentifié, accès aux routes protégées.
- **Scénario Nominal** :
    1. L'utilisateur saisit son numéro de téléphone et son mot de passe.
    2. Le système vérifie les identifiants.
    3. Le système génère et renvoie un token JWT.
- **Scénarios Alternatifs** :
    - *Identifiants erronés* : Message "Identifiants invalides".

#### UC-U03 : Se déconnecter
- **Acteurs** : Utilisateur
- **Pré-conditions** : Connecté.
- **Post-conditions** : Session terminée, token invalidé côté client.
- **Scénario Nominal** :
    1. L'utilisateur clique sur "Déconnexion".
    2. Le système supprime le token du stockage sécurisé mobile.
    3. Redirection vers l'écran de Login.
- **Scénarios Alternatifs** :
    - *Action annulée* : L'utilisateur annule lors de la boîte de dialogue de confirmation.

#### UC-U04 : Consulter le Dashboard
- **Acteurs** : Utilisateur
- **Pré-conditions** : Connecté, compteur lié.
- **Post-conditions** : Statistiques affichées.
- **Scénario Nominal** :
    1. L'utilisateur ouvre l'onglet Accueil.
    2. Le système récupère le solde, la consommation et les dernières recharges.
    3. Le système affiche les graphiques et badges.
- **Scénarios Alternatifs** :
    - *Erreur réseau* : Le système affiche un message d'erreur de connexion.
    - *Compteur non lié* : Le système invite l'utilisateur à lier son premier compteur.

#### UC-U06 : Délier un compteur
- **Acteurs** : Utilisateur
- **Pré-conditions** : Connecté, compteur lié à l'utilisateur.
- **Post-conditions** : Compteur libéré, disponible pour un autre lien.
- **Scénario Nominal** :
    1. L'utilisateur accède aux détails de son compteur.
    2. L'utilisateur confirme la suppression du lien.
    3. Le système met à jour la base de données (`user_id = NULL`).
- **Scénarios Alternatifs** :
    - *Compteur introuvable* : Le système renvoie une erreur 404.
    - *Erreur serveur* : Impossible de mettre à jour le lien, message d'erreur.

#### UC-U08 : Consulter l'historique
- **Acteurs** : Utilisateur
- **Pré-conditions** : Connecté.
- **Post-conditions** : Liste des transactions affichée.
- **Scénario Nominal** :
    1. L'utilisateur accède à l'onglet Historique.
    2. Le système récupère toutes les recharges associées à son `user_id`.
    3. Le système affiche les montants, dates et statuts.
- **Scénarios Alternatifs** :
    - *Aucune transaction* : Le système affiche un message "Aucune recharge effectuée".
    - *Erreur réseau* : Impossible de récupérer les données.

#### UC-U09 : Voir son profil
- **Acteurs** : Utilisateur
- **Pré-conditions** : Connecté.
- **Post-conditions** : Informations affichées.
- **Scénario Nominal** :
    1. L'utilisateur ouvre l'onglet Compte.
    2. Le système affiche son pseudo, téléphone et email.
    3. L'utilisateur peut choisir de modifier ses informations ou changer son mot de passe.
- **Scénarios Alternatifs** :
    - *Profil non trouvé* : Rare, mais le système renvoie une erreur 404.
    - *Erreur de chargement* : Problème réseau persistant.

#### UC-U05 : Lier un compteur
- **Acteurs** : Utilisateur
- **Pré-conditions** : Utilisateur connecté, possède un token valide de compteur.
- **Post-conditions** : Le compteur est associé à l'utilisateur.
- **Scénario Nominal** :
    1. L'utilisateur scanne le QR Code ou saisit manuellement le token.
    2. Le système vérifie la validité du token.
    3. Le système vérifie que le compteur n'est pas déjà attribué.
    4. Le système lie le `user_id` au `meter_id`.
- **Scénarios Alternatifs** :
    - *Token invalide* : Message d'erreur "Compteur inexistant".
    - *Déjà attribué* : Message d'erreur "Compteur déjà lié à un autre compte".

#### UC-U07 : Effectuer une recharge
- **Acteurs** : Utilisateur, Système MQTT, Device
- **Pré-conditions** : Utilisateur connecté, compteur lié.
- **Post-conditions** : Recharge créée, vanne ouverte si succès.
- **Scénario Nominal** :
    1. L'utilisateur choisit le montant et le mode de paiement (OM/MOMO/CASH).
    2. Le système crée une transaction `PENDING`.
    3. Après confirmation du paiement, le statut passe à `SUCCEEDED`.
    4. Le système envoie une commande MQTT au compteur physique.
    5. Le compteur ouvre la vanne.
- **Scénarios Alternatifs** :
    - *Échec paiement* : Transaction passe à `FAILED`.
    - *Timeout MQTT* : Notification d'erreur de communication.

### 10.2 Cas d'Utilisation — Administrateur (Admin)

#### UC-A04 : Créer un compteur
- **Acteurs** : Administrateur
- **Pré-conditions** : Admin connecté.
- **Post-conditions** : Compteur virtuel créé dans le système.
- **Scénario Nominal** :
    1. L'admin saisit le numéro de série du compteur.
    2. Le système génère un ID unique et un token d'appairage (UUID).
    3. Le système enregistre le compteur à l'état `INACTIVE`.
- **Scénarios Alternatifs** :
    - *Série en doublon* : Le système rejette car le `serial_id` doit être unique.

#### UC-A10 : Lier un device physique
- **Acteurs** : Administrateur
- **Pré-conditions** : Admin connecté, compteur virtuel existant.
- **Post-conditions** : Device IoT lié au compteur.
- **Scénario Nominal** :
    1. L'admin sélectionne un compteur virtuel.
    2. L'admin saisit le `device_id` (DevEUI LoRaWAN).
    3. Le système associe l'identité physique à l'identité logique.
- **Scénarios Alternatifs** :
    - *Device déjà lié* : Erreur si le device est affecté à un autre compteur.

#### UC-A14 : Générer un rapport
- **Acteurs** : Administrateur
- **Pré-conditions** : Admin connecté.
- **Post-conditions** : Rapport généré et disponible en téléchargement.
- **Scénario Nominal** :
    1. L'admin choisit les dates (début/fin) et le format (CSV).
    2. Le système agrège les données de consommation et de recharges.
    3. Le système génère le fichier.
- **Scénarios Alternatifs** :
    - *Aucune donnée* : Message informant qu'aucune donnée n'est disponible pour cette période.

#### UC-A01 : S'inscrire (Admin)
- **Acteurs** : Administrateur
- **Pré-conditions** : Aucune.
- **Post-conditions** : Compte Admin créé.
- **Scénario Nominal** :
    1. L'admin remplit le formulaire d'inscription en spécifiant le type `admin`.
    2. Le système vérifie l'unicité des informations.
    3. Le système crée le compte admin avec les privilèges de gestion.
- **Scénarios Alternatifs** :
    - *Téléphone déjà utilisé* : Message d'erreur "Ce compte existe déjà".
    - *Données invalides* : Erreur de validation sur les champs obligatoires.

#### UC-A03 : Consulter le Dashboard Admin
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté en tant qu'admin.
- **Post-conditions** : Statistiques globales affichées.
- **Scénario Nominal** :
    1. L'admin ouvre le Dashboard.
    2. Le système calcule le revenu total, le volume d'eau distribué et compte les utilisateurs/compteurs actifs.
    3. Le système affiche les listes d'activité récente.
- **Scénarios Alternatifs** :
    - *Erreur réseau* : Le système affiche un message d'impossibilité de charger les stats.

#### UC-A05 : Lister les compteurs
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté (admin).
- **Post-conditions** : Liste complète affichée.
- **Scenario Nominal** :
    1. L'admin navigue vers l'onglet Compteurs.
    2. Le système récupère tous les compteurs liés à cet admin.
    3. Affiche les statuts (ACTIVE, INACTIVE) et les utilisateurs assignés.
- **Scénarios Alternatifs** :
    - *Aucun compteur géré* : Message "Aucun compteur n'est encore enregistré".

#### UC-A06 : Voir détails d'un compteur
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté, compteur sélectionné.
- **Post-conditions** : Vue détaillée affichée.
- **Scenario Nominal** :
    1. L'admin clique sur un compteur dans la liste.
    2. Le système affiche les informations techniques (DevEUI, RSSI, Batterie), le token actuel et l'historique spécifique des recharges.
- **Scénarios Alternatifs** :
    - *Compteur inexistant* : Retourne une erreur 404.

#### UC-A07 : Modifier un compteur
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté, compteur existant.
- **Post-conditions** : Modifications enregistrées.
- **Scenario Nominal** :
    1. L'admin modifie l'état de service (ex: passage en MAINTENANCE).
    2. Le système enregistre l'état et met à jour l'affichage.
- **Scénarios Alternatifs** :
    - *Données invalides* : Erreur lors de la validation des nouvelles données.

#### UC-A09 : Générer un token
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté, compteur existant.
- **Post-conditions** : Nouveau token UUID généré.
- **Scenario Nominal** :
    1. L'admin demande la régénération du token d'appairage.
    2. Le système invalide l'ancien token et crée un nouveau.
    3. Le nouveau QR Code est prêt pour l'utilisateur.
- **Scénarios Alternatifs** :
    - *Erreur serveur* : Impossible de générer l'UUID, message d'erreur.

#### UC-A12 : Lister les utilisateurs
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté.
- **Post-conditions** : Liste des clients affichée.
- **Scenario Nominal** :
    1. L'admin accède à l'onglet Utilisateurs.
    2. Le système liste tous les comptes ayant lier au moins un compteur géré par cet admin.
- **Scénarios Alternatifs** :
    - *Aucun utilisateur* : Message informative "Aucun client actif".

#### UC-A15 : Lister les rapports
- **Acteurs** : Administrateurs
- **Pré-conditions** : Connecté.
- **Post-conditions** : Historique des rapports générés affiché.
- **Scenario Nominal** :
    1. L'admin consulte l'historique des rapports.
    2. Le système affiche la liste des fichiers générés précédemment avec leurs dates.
- **Scénarios Alternatifs** :
    - *Liste vide* : Message "Aucun rapport généré jusqu'à présent".

#### UC-A08 : Supprimer un compteur
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté, compteur existant.
- **Post-conditions** : Compteur et données liées supprimés.
- **Scenario Nominal** :
    1. L'admin choisit "Supprimer" sur un compteur.
    2. Le système demande une confirmation.
    3. Le système supprime l'entrée en base de données (cascade sur les recharges).
- **Scénarios Alternatifs** :
    - *Compteur avec lien actif* : Le système peut refuser ou prévenir avant suppression irréversible.

#### UC-A11 : Recharger manuellement
- **Acteurs** : Administrateur, Système MQTT
- **Pré-conditions** : Connecté, compteur attribué à un utilisateur.
- **Post-conditions** : Solde rechargé, vanne ouverte.
- **Scenario Nominal** :
    1. L'admin accède aux détails d'un compteur.
    2. L'admin saisit un montant payé directement en CASH.
    3. Le système crée une recharge `SUCCEEDED`.
    4. Le système déclenche l'ouverture de la vanne via MQTT.
- **Scénarios Alternatifs** :
    - *Compteur non attribué* : Message d'erreur demandant d'assigner un utilisateur d'abord.

#### UC-A13 : Consulter l'historique admin
- **Acteurs** : Administrateur
- **Pré-conditions** : Connecté.
- **Post-conditions** : Historique global ou filtré affiché.
- **Scenario Nominal** :
    1. L'admin accède à l'onglet Historique Global.
    2. L'admin peut filtrer par utilisateur, par compteur ou par date.
    3. Le système affiche toutes les recharges (OM, MOMO, CASH) correspondantes avec leur statut final.
- **Scénarios Alternatifs** :
    - *Erreur de filtrage* : Message si les critères ne correspondent à aucun enregistrement.

#### UC-A16 : Mettre à jour statut recharge
- **Acteurs** : Administrateur, Système MQTT
- **Pré-conditions** : Connecté, transaction existante.
- **Post-conditions** : Statut de la recharge mis à jour, notification MQTT si succès.
- **Scenario Nominal** :
    1. L'admin sélectionne une recharge `PENDING`.
    2. L'admin change manuellement le statut en `SUCCEEDED`.
    3. Le système met à jour la base de données et déclenche l'ouverture de la vanne si un device est lié.
- **Scénarios Alternatifs** :
    - *Droit insuffisant* : Erreur si l'admin n'a pas les droits sur ce compteur.
    - *Erreur MQTT* : Impossible de notifier le device malgré le succès du statut.

- **Scénarios Alternatifs** :
    - *Compteur déjà libre* : Notification informant que le compteur n'est pas lié.

---

## 11. Diagramme de Déploiement

Le diagramme de déploiement cartographie l'architecture physique de WaterPaid. Il montre comment l'application Flutter communique avec le backend hébergé sur Render, et comment ce dernier interagit avec Supabase pour les données et ChirpStack pour la couche LoRaWAN. C'est une vue "Infrastructure as Code" du système.

```plantuml

Ce diagramme illustre l'infrastructure physique et la distribution des composants sur les différents nœuds.

```plantuml
@startuml WaterPaid_Deployment
node "Smartphone (Android/iOS)" {
  artifact "Application Mobile (Flutter)" as MobileApp
}

node "Cloud Platform (Render)" {
  component "Backend API (FastAPI)" as Backend
  component "MQTT Subscriber" as MQTTSub
}

node "Supabase / PostgreSQL" {
  database "Base de données Relationnelle" as DB
}

node "ChirpStack (LoRaWAN Network Server)" {
  component "LoRa Gateway Connector" as CS
}

node "Dispositifs IoT (Hardware)" {
  artifact "Compteur Intelligent (LoRaWAN)" as Device
}

cloud "Internet" as Internet
cloud "Réseau LoRaWAN" as LoRa

MobileApp -- Internet : HTTPS / REST / WS
Internet -- Backend
Backend -- DB : SQLAlchemy
CS -- LoRa
LoRa -- Device
CS ..> CS : MQTT Bridge
CS --(0-- MQTTSub : MQTT Protocol
MQTTSub -- Backend : Integration
@enduml
```

---

## 12. Diagramme de Composants

Cette vue modulaire décompose l'application en briques logiques : le client mobile (gestion d'état Riverpod, Dio), l'API FastAPI (Routers, Services) et les interfaces de persistance. Elle permet de visualiser les dépendances logicielles et les flux d'information entre les modules.

```plantuml

Ce diagramme montre l'organisation logique des composants logiciels et leurs interfaces.

```plantuml
@startuml WaterPaid_Components
package "Application Mobile (Flutter)" {
  [UI Screens (Widgets)] as UI
  [Riverpod States (Providers)] as State
  [Dio API Client] as Dio
  [WebSocket Client] as WSClient
  
  UI --> State
  State --> Dio
  State --> WSClient
}

package "Backend API (FastAPI)" {
  interface "REST API" as IREST
  interface "WebSocket" as IWS
  
  [Routers] as RT
  [Services (Business Logic)] as SV
  [Repositories (Data Access)] as RP
  [MQTT Handler] as MH
  
  IREST -- RT
  IWS -- RT
  RT --> SV
  SV --> RP
  MH --> SV
}

database "PostgreSQL" as Postgres {
  [Entités SQLAlchemy] as Ent
}

Dio ..> IREST : appelle
WSClient ..> IWS : s'abonne
RP --> Ent : persiste
@enduml
```

---

## 13. Diagramme d'Objets (Instance système)

Le diagramme d'objets permet de visualiser un instantané du système avec des données concrètes. Il illustre comment les entités définies dans le diagramme de classes s'instancient réellement : un utilisateur "John Doe" possédant un compteur spécifique, lié à un matériel IoT identifié, et ayant effectué une transaction de recharge réussie.

Exemple d'une instance du système à un instant T (Un utilisateur avec un compteur et une recharge).

```plantuml
@startuml WaterPaid_Objects
object "Utilisateur : John Doe" as U1 {
  id = "usr-123"
  phone = "690000000"
}

object "Compteur : Salon" as M1 {
  id = "met-456"
  serial = "WP-2026-X1"
  token = "token-abcd"
  state = ACTIVE
  attributed = true
}

object "Device : Node_01" as D1 {
  dev_eui = "70B3D5XX"
  battery = 85
  valve = "open"
}

object "Recharge : R01" as R1 {
  amount = 1000
  volume = 100
  status = SUCCEEDED
  method = MOMO
}

U1 "1" -- "1" M1 : possède
M1 "1" -- "1" D1 : lié à
U1 "1" -- "0..*" R1 : a payé
M1 "1" -- "0..*" R1 : concerne
@enduml
```

---

## 14. Diagramme de Classes — Niveau Conception (Détaillé)

Ce dernier diagramme est la vue la plus proche de l'implémentation finale. Il détaille la structure interne du code source FastAPI, mettant en lumière le "Service Pattern" et le "Repository Pattern". On y voit précisément comment les Routers délèguent la logique aux Services, qui eux-mêmes utilisent les Repositories pour manipuler les modèles persistants. C'est le guide technique de référence pour tout développeur rejoignant le projet.

Ce diagramme présente l'architecture logicielle complète du backend, montrant la séparation entre les contrôleurs (Routers), la logique métier (Services), l'accès aux données (Repositories) et les modèles persistants.

```plantuml
@startuml WaterPaid_Design_Class_Diagram
skinparam classAttributeIconSize 0
skinparam packageStyle rectangle

package "Layer: Web/API (FastAPI Routers)" {
  class UserRouter {
    + get_dashboard(id: str)
    + create_refill(id: str, data: RefillCreate)
    + assign_meter(data: MeterAssign)
  }
  class AdminRouter {
    + get_stats()
    + create_meter(data: MeterCreate)
    + link_device(meter_id: str, dev_id: str)
  }
  class AuthRouter {
    + signup(data: SignupRequest)
    + login(data: LoginRequest)
  }
}

package "Layer: Business Logic (Services)" {
  class UserService {
    - user_repo: UserRepository
    - meter_repo: MeterRepository
    + get_dashboard(user_id: str): Dict
    + create_refill(meter_id: str, data: RefillCreate): Dict
  }
  class AdminService {
    - admin_repo: AdminRepository
    - meter_repo: MeterRepository
    + get_dashboard_stats(): Dict
    + create_meter(data: MeterCreate): Dict
    + link_device(m_id: str, d_id: str): Dict
  }
  class MQTTService {
    - device_repo: DeviceRepository
    + notify_refill_succeeded(m_id: str, vol: float)
    + process_uplink(eui: str, payload: dict)
  }
}

package "Layer: Data Access (Repositories)" {
  class BaseRepository {
    # db: Session
    + get_by_id(id: any)
    + create(obj: any)
    + update(obj: any)
    + delete(id: any)
  }
  class MeterRepository extends BaseRepository {
    + get_by_token(token: str)
    + get_by_dev_eui(eui: str)
  }
  class RefillRepository extends BaseRepository {
    + get_history_by_user(u_id: str)
    + get_sum_volume(m_id: str): float
  }
}

package "Layer: Persistence (SQLAlchemy Models)" {
  class User {
    + user_id: UUID <<PK>>
    + password_hash: String
  }
  class Meter {
    + meter_id: UUID <<PK>>
    + token: UUID
    + attributed: Boolean
  }
  class Refill {
    + refill_id: UUID <<PK>>
    + status: RefillStateEnum
    + volume: Float
  }
}

' --- Interactions ---
UserRouter ..> UserService : injecte
AdminRouter ..> AdminService : injecte
UserService --> MeterRepository : utilise
UserService --> RefillRepository : utilise
AdminService --> MeterRepository : utilise
MeterRepository o-- Meter : gère
RefillRepository o-- Refill : gère

@enduml
```
