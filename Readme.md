 Visi aprašyti žingsniai yra įgyvendinti scripte `datacollector_install.sh`
 
## Datahub diegimas

1. Įdiegti docker

Oficiali instrukcija: https://docs.docker.com/engine/install/ubuntu/  

2. Leisti administruojančiam vartotojui valdyti docker (neprivaloma):

Oficiali instrukcija: https://docs.docker.com/engine/install/linux-postinstall/

3. Parsisiųsti `datahub` `docker-compose` šabloną į instaliacijos aplanką (įprastai `/opt/datahub`):


    cd /opt
    mkdir datahub
    cd datahub
    git clone https://github.com/energy-advice/datacollector-template.git ./ 

4. Užpildyti reikalingus laukus konfigūracijos failuose:

`datacollector.properties`:
* `---SERVICE_ID_NOT_SET---` pakeisti į pasirinką, dažniausiai `datacollector`.
* `---TOKEN_NOT_SET---` pakeisti į EASAS vartotojo, kurio vardu bus keliami duomenys, prisijungimo tokeną
kurį galima gauti EASAS vartotojų valdymo lange, ant vartotojo paspaudus dešiniu pelės klavišu ir pasirinkus
"JWT generation".
Būtina pasirinkti teisę `DATASET_DATA_PUSH` ir nustatyti atitinkamą `TTL` (time to live).
* Jei kompanija nėra pirmame EASAS serveryje pakeisti `lt.energyadvice.datacollector.remoteServiceUrl` vertę
į atitinkamą (formatas: `https://easas.energyadvice.lt/EASAS/rest`)

`.env`:
* `---DATAHUB_TOKENAS---` pakeisti į datahub tokeną, kuris gaunamas EASAS Datahubs skiltyje paspaudus `Generate`
* mygtuką

5. Paleisti `datahub` su `docker compose up -d`
6. `datahub` turėtų atsirasti EASAS Datahubs sąraše, kur galima atlikti skaitymo konfigūraciją
