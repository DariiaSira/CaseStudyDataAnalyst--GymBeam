# Case Study - Medior Data Analyst in GymBeam

## 1. Návrh dátového modelu pre e-commerce platformu

Predstavte si, že pracujete pre e-commerce spoločnosť, ktorá predáva produkty online. Vašou úlohou je navrhnúť optimálny dátový model, ktorý bude podporovať:  
1. Správu produktov a ich kategórií  
2. Zákaznícke objednávky  
3. Históriu transakcií  
4. Analýzu predajov podľa rôznych dimenzií (napr. čas, produkt, kategória, región)  

---

### Zadanie

#### 1. Navrhnite dátový model vo forme ER diagramu (Entity-Relationship diagram), ktorý pokryje nasledovné požiadavky:
- **Produkty**: ID, názov, cena, opis, dostupnosť, kategória  
- **Kategórie**: ID kategórie, názov kategórie, nadradená kategória (hierarchia kategórií)  
- **Zákazníci**: ID zákazníka, meno, email, adresa (vrátane regiónu), dátum registrácie  
- **Objednávky**: ID objednávky, zákazník, dátum objednávky, stav objednávky, položky objednávky  
- **Položky objednávky**: ID položky, produkt, množstvo, cena za jednotku  
- **Transakcie**: ID transakcie, objednávka, dátum, spôsob platby, suma

#### Riešenie

1. **Identifikovať entity**  
   - Produkty, Kategórie, Zákazníci, Objednávky, Položky objednávky, Transakcie  
   - pomocná: Regióny (pre adresy a analytiku)

2. **Určiť kľúčové atribúty**  
   - ID, názvy, dátumy, sumy, väzby na súvisiace tabuľky

3. **Definovať vzťahy a kardinality**  
   - Kategórie (self-FK) → hierarchia „1:N“ -- Jedna kategória môže mať viac podkategórií. Self-referencia umožňuje stromovú štruktúru.  
   - Kategórie ↔ Produkty → 1:N  -- Každý produkt patrí práve do jednej kategórie, ale jedna kategória môže obsahovať mnoho produktov. 
   - Regióny ↔ Zákazníci → 1:N  -- Zákazník sa nachádza v jednom regióne, ale v regióne môže byť veľa zákazníkov.  
   - Zákazníci ↔ Objednávky → 1:N  -- Každý zákazník môže vytvoriť viacero objednávok, ale objednávka patrí iba jednému zákazníkovi.  
   - Objednávky ↔ Položky objednávky → 1:N  -- Objednávka sa skladá z viacerých položiek, ale každá položka je naviazaná na jednu objednávku.
   - Produkty ↔ Položky objednávky → 1:N  -- Jeden produkt sa môže objaviť vo viacerých položkách (v rôznych objednávkach), ale položka vždy obsahuje iba jeden produkt.  
   - Objednávky ↔ Transakcie → 1:N  -- Objednávka môže mať jednu alebo viac transakcií (napr. ak zákazník zaplatí na viac častí), ale transakcia patrí len k jednej objednávke. Prípady: čiastočná platba (split payment), opakovaný pokus o platbu, doplatok/refund. V jednoduchých e-shopoch je to väčšinou 1:1, ale model je navrhnutý flexibilne.  

4. **Nastaviť PK/FK**  
   - PK: všetky ID  
   - FK: väzby podľa kategórií, regiónov, zákazníkov, objednávok a produktov  

5. **ER diagram**
   - Diagram bol vytvorený na platforme [dbdiagram.io](https://dbdiagram.io/). Do repozitára vložím aj kód ([`oltp.sql`](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/oltp.sql)) a pridám screenshot schémy dole.

<img width="2207" height="842" alt="image" src="https://github.com/user-attachments/assets/3f88e05a-80d1-4fa2-863c-8545bc559c6a" />


#### 2. Definujte dimenzie a faktové tabuľky pre analytické potreby:
- Navrhnite dátový model (napr. **star schéma** alebo **snowflake schéma**), ktorý bude slúžiť na analýzu predajov podľa času, produktov, kategórií a regiónov  

#### Riešenie

1. **Voľba schémy**
   - Použila som **snowflake** namiesto hviezdy, pretože kategórie produktov majú hierarchiu (podkategórie → kategória → sekcia).  
Samostatná tabuľka `DimCategory` so vzťahom parent→child umožňuje čistejšie analyzovať predaje na rôznych úrovniach kategórií a znižuje duplicitu dát.

3. **Definovanie faktov**
   - Model obsahuje **dve rôzne udalosti**, preto sú vytvorené dve faktové tabuľky s rôznym zrnom:  
   - **`FactSales`** – uchováva predaje na úrovni položky objednávky (koľko kusov, aká cena). Zrno je nastavené takto, aby bolo možné presne analyzovať podľa produktu a kategórie.  
   - **`FactTransactions`** – uchováva platobné transakcie (suma, spôsob platby). Je oddelená, pretože platba a predaj nemusia byť vždy 1:1 (napr. pokusy o platbu, refundy alebo kombinácia viacerých metód).

3. **Definovanie dimenzií**
   - **`DimDate`** – umožňuje analýzu v čase (dni, mesiace, roky).  
   - **`DimProduct`** – uchováva informácie o produkte.  
   - **`DimCategory`** – reprezentuje hierarchiu kategórií.  
   - **`DimCustomer`** – údaje o zákazníkovi, potrebné na spojenie s regiónom.  
   - **`DimRegion`** – uchováva región a krajinu, pre analýzy podľa lokality.  
   - **`DimPaymentMethod`** – porovnanie a analýza spôsobov platieb.  

4. **Spôsob analýzy**
   - Podľa **času** – cez `DimDate`.  
   - Podľa **produktov a kategórií** – `FactSales` prepojený s `DimProduct` a `DimCategory`.  
   - Podľa **regiónov** – `FactSales` alebo `FactTransactions` cez `DimRegion` (region_key je priamo vo faktoch pre rýchlejšie dotazy).  
   - Podľa **spôsobov platieb** – `FactTransactions` cez `DimPaymentMethod`.

5. **Snowflake Schema in DWH**
   - Schema bola vytvorena tiež na platforme [dbdiagram.io](https://dbdiagram.io/). Do repozitára vložím aj kód ([`dwh.sql`](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/dwh.sql)) a pridám screenshot schémy dole.

<img width="2124" height="902" alt="image" src="https://github.com/user-attachments/assets/7a3937b5-3f10-4a46-a070-d57e8cf17105" />

#### 3. Identifikujte primárne a cudzie kľúče

#### Riešenie

- Každá dimenzia má vlastný **surrogátny kľúč** (`*_key`) ako primárny kľúč (PK).  
  - `DimDate.date_key`, `DimProduct.product_key`, `DimCategory.category_key`, `DimCustomer.customer_key`, `DimRegion.region_key`, `DimPaymentMethod.payment_method_key`.  

- Faktové tabuľky obsahujú **cudzie kľúče (FK)** na tieto dimenzie:  
  - `FactSales`: `order_date_key → DimDate`, `customer_key → DimCustomer`, `product_key → DimProduct`, `region_key → DimRegion`.  
  - `FactTransactions`: `txn_date_key → DimDate`, `customer_key → DimCustomer`, `region_key → DimRegion`, `payment_method_key → DimPaymentMethod`.  

- Okrem toho fakty obsahujú aj **biznis kľúče** (`*_id_bk`) ako atribúty na trasovanie do OLTP systému,  
  ale nie sú použité ako PK/FK. Týmto prístupom sú OLTP identifikátory oddelené od DWH a je umožnená správa historických zmien (napr. SCD).


#### 4. Pripravte SQL skript na definovanie tabuliek podľa vášho návrhu:

#### Riešenie

   - [**`oltp.sql`**](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/oltp.sql) – operatívna (transakčná) schéma systému e-commerce. Obsahuje tabuľky pre produkty, kategórie, zákazníkov, objednávky, položky objednávok a transakcie. Táto časť predstavuje **source-of-truth** pre všetky obchodné dáta.

   - [**`dwh.sql`**](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/dwh.sql) – analytický dátový sklad (DWH) navrhnutý vo forme **snowflake**. Obsahuje faktové tabuľky (`FactSales`, `FactTransactions`) a dimenzie (`DimDate`, `DimProduct`, `DimCategory`, `DimCustomer`, `DimRegion`, `DimPaymentMethod`). Tento model je optimalizovaný pre reporting a umožňuje analýzu predajov podľa času, produktov, kategórií a regiónov.

### Dodatočná otázka na diskusiu
- Ako by ste riešili **historické zmeny** (napr. zmena ceny produktu, adresa zákazníka)?

História zmien (napríklad cena produktu alebo adresa zákazníka) sa vo firmách rieši tak, aby sme vedeli pozrieť na dáta tak, ako vyzerali v minulosti. Najčastejšie sa používa SCD Type 2, kde sa pri zmene nevymení pôvodný riadok, ale pridá sa nový s dátumom platnosti. Takto sa dá správne zistiť, aká cena alebo aký región platili v čase objednávky a fakty sa napoja na túto verziu dimenzie. Je to dôležité, pretože pri reportoch za minulý rok nechceme vidieť dnešné ceny alebo adresy.

V praxi to znamená, že vo FactSales sa vždy ukladá aj reálna cena z objednávky a v dimenziách sa držia historické údaje, ako napríklad kategória alebo región zákazníka. Menšie úpravy, ktoré nie sú dôležité (napr. oprava mena), sa dajú riešiť jednoduchým prepísaním (SCD Type 1). Ale pri produktoch a zákazníkoch sa bežne používa SCD2, aby reporty ukazovali presný stav v čase predaja.

---

## 2. Analytická úloha

Vašou úlohou bude spracovať vzorové tabuľky z prostredia e-commerce, dopočítať požadované metriky a vizualizovať ich.  

### Poskytnuté zdrojové tabuľky
- **`sales_order`** – zoznam 30 000 objednávok z roku 2024,  
- **`sales_order_item`** – položky, ktoré sa nachádzajú vo vybraných objednávkach.  

### Použité nástroje
- **ETL nástroj:** [Keboola](https://help.keboola.com/) – nahratie a transformácia dát (SQL / Python),  
- **BI nástroj:** vami zvolený (bezplatný účet), určený na vizualizáciu výsledkov.

#### Riešenie
Najskôr som sa zaregistrovala na platforme Keboola, s ktorou som pracovala prvýkrát. Keďže vstupné dáta boli poskytnuté vo formáte CSV, nastavila som komponent CSV Import a nahrala som tam pripravené datasety.

<img width="1573" height="1207" alt="image" src="https://github.com/user-attachments/assets/44fc3f02-aed2-4d43-91ad-65571943131b" />

Na časť Data Transformation som zvolila jazyk Python a kód som implementovala v prostredí [Workspace – Jupyter Notebook](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/notebook.ipynb). V tomto kroku som dáta načítala, skontrolovala a odstránila prázdne hodnoty (detailný postup je vysvetlený priamo v kóde). Po vyčistení som datasety uložila do výstupného adresára, aby mohli byť použité v ďalších úlohách.

Ako BI nástroj som pôvodne zvolila Power BI Service, avšak narazila som na problém s autorizáciou účtu. Troubleshooting a oboznámenie sa s novou platformou mi zabrali určitý čas, no keďže bolo pre mňa prioritou odovzdať zadanie načas, rozhodla som sa pokračovať v práci v lokálnej verzii Power BI Desktop. Finálny [súbor](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/GymBeam.pbix) s riešeniami vizualizácií prikladám v repozitári spolu s touto dokumentáciou.

<img width="927" height="987" alt="image" src="https://github.com/user-attachments/assets/96c42c70-3486-4a1c-a276-5d6c460e46f3" />
<img width="1402" height="609" alt="image" src="https://github.com/user-attachments/assets/bafd5651-ce33-4805-956b-a5185e8f0f35" />


### 2.1. Doplniť názov mesta k objednávke
- V dátach chýba názov mesta, k dispozícii je iba PSČ.  
- Doplniť názov mesta k objednávkam (napr. pomocou externej knižnice alebo datasetu).  
- Vizualizovať:  
  - **TOP 20 miest** vo forme tabuľky podľa metriky **AOV (Average Order Value)**,
  - **mapu** s počtom vytvorených objednávok z jednotlivých miest.

#### Riešenie
V pôvodných dátach sa nachádzal iba poštový kód (PSČ), preto som pripravila externý dataset na mapovanie postal_code → city a doplnila názov mesta ku každej objednávke.
<img width="800" height="807" alt="image" src="https://github.com/user-attachments/assets/ce3cb2cb-d78c-466a-b902-70ce46ea39d7" />

Po doplnení som prepojila tabuľky sales_order a sales_items a vytvorila základné metriky:
```
-- Celkový predaj v EUR
Total Sales EUR =
SUMX (
    sales_items,
    sales_items[sold_qty] *
    sales_items[product_price_local_currency] *
    RELATED ( sales_order[currency_rate] )
)

-- Počet objednávok
Orders Count =
DISTINCTCOUNT ( sales_order[pk_sales_order] )

-- Priemerná hodnota objednávky (AOV)
AOV =
DIVIDE ( [Total Sales EUR], [Orders Count] )

```
<img width="1781" height="969" alt="image" src="https://github.com/user-attachments/assets/fc39660e-3081-4c30-844d-3367b58cdedf" />


### 2.2. Nová kamenná predajňa
- GymBeam má aktuálne predajne v **Košiciach, Budapešti a Prahe**.  
- Na základe vzorky dát (prípadne doplnkových datasetov) určiť vhodnú lokalitu pre **novú predajňu**.  
- Vysvetliť dôvody výberu mesta.  
- Výstup nie je nutné vizualizovať v BI nástroji.
  
#### Riešenie

Na základe datasetu postal_code → city som analyzovala objednávky podľa miest. Predajne GymBeam sa už nachádzajú v Košiciach, Budapešti a Prahe, preto som tieto lokality zo zoznamu vylúčila. Porovnala som mestá podľa počtu objednávok a identifikovala najvýkonnejšie lokality. Ukázalo sa, že Žilina patrí medzi mestá s najvyšším počtom objednávok mimo existujúcich predajní. Tento výsledok naznačuje silný dopyt po produktoch a atraktívny potenciál pre retail. Preto som zvolila Žilinu ako vhodnú lokalitu pre novú kamennú predajňu GymBeam.

<img width="1766" height="1003" alt="image" src="https://github.com/user-attachments/assets/0743f26c-6af3-4191-9fb0-7efd00896991" />

### 2.3. Vypočítať priemernú mesačnú maržu produktu
- Vypočítať **priemernú mesačnú maržu** pre každý produkt.  
- Vizualizovať vývoj marže v čase s možnosťou filtrovať konkrétny produkt.
  
#### Riešenie

Najskôr som si pripravila dátumový stĺpec YearMonth, aby som mohla analyzovať maržu v mesačnom rozdelení:

```
YearMonth = FORMAT ( sales_order[created_at], "YYYY-MM" )
```

Na výpočet marže som vytvorila metriku Total Margin EUR, ktorá počíta rozdiel medzi výnosom a nákladom:

```
Total Margin EUR =
SUMX (
    sales_items,
    sales_items[sold_qty] * sales_items[product_price_local_currency] * RELATED ( sales_order[currency_rate] )
    - sales_items[sold_qty] * sales_items[product_cost_eur]
)
```

Následne som pripravila metriku Avg Monthly Margin EUR, ktorá vracia priemernú mesačnú maržu pre každý produkt:

```
Avg Monthly Margin EUR =
AVERAGEX (
    VALUES ( sales_order[YearMonth] ),
    [Total Margin EUR]
)
```

Do reportu som pridala filter s vyhľadávaním produktov naľavo, v strede sa nachádza analýza vývoja marže v čase (line chart, kde na osi X bol YearMonth a na osi Y hodnota marže=, a napravo tabuľka priemernej mesačnej marže pre každý produkt zoradená od najvyššej hodnoty.

<img width="1786" height="1005" alt="image" src="https://github.com/user-attachments/assets/3db3d537-936e-46dd-b0b3-d65cbbac9138" />

### 2.4. Vypočítať najpredávanejšie dvojice produktov
- Identifikovať **najčastejšie predávané dvojice produktov** v rámci jednej objednávky.  
- Do dvojíc nezapočítavať produkty pridané ako darček.  
- Poskytnúť zoznam **TOP 10 dvojíc** spolu s percentuálnym podielom objednávok, kde sa tieto dvojice vyskytli.  
- Vizualizácia v BI nie je nutná.  

#### Riešenie

Túto úlohu som riešila v Pythone [Task 2.4](https://github.com/DariiaSira/CaseStudyDataAnalyst--GymBeam/blob/main/Task2_4.ipynb). Najskôr som vyriešila kvalitu dát tým, že som odstránila riadky s chýbajúcim alebo „Unknown“ fk_item.
Následne som aplikovala filtrovanie darčekov – produkty s cenou <= 0 som zo zoznamu vylúčila. Pre každú objednávku som vytvorila množinu produktov a z nej vygenerovala všetky možné dvojice (kombinácie po 2). Nakoniec som spočítala frekvenciu týchto dvojíc, vypočítala ich percentuálny podiel z objednávok a zostavila zoznam Top 10 najčastejšie predávaných dvojíc.

<img width="978" height="443" alt="image" src="https://github.com/user-attachments/assets/ddaa992c-3629-40f4-86d8-3246c263898c" />

## 3. Výkonnostný problém v SQL transformácii

**Situácia:** Kolega nasadil SQL transformáciu do produkcie. Spočiatku fungovala dobre, no časom sa doba spracovania výrazne predĺžila.  
**Úloha:**  
- Identifikujte najčastejšie príčiny tohto správania.  
- Navrhnite konkrétne, praktické kroky na odstránenie problému.

#### Riešenie
Najčastejšie príčiny, prečo SQL transformácia časom začína bežať pomalšie, v prvom rade ide o rast objemu dát: rovnaký dopyt, ktorý bol navrhnutý pre milióny riadkov, musí časom spracovávať desiatky či stovky miliónov. Druhým častým faktorom sú zastaralé štatistiky, v dôsledku ktorých optimalizátor nesprávne odhaduje selektivitu a vyberá nevýhodný plán. Dôležitá je aj fragmentácia indexov alebo úplná absencia indexov na kľúčových stĺpcoch, čo vedie k skenovaniu celej tabuľky. Taktiež parameter sniffing – situácia, keď sa do cache uloží nevhodný plán vykonania pre „zlý“ parameter, ako aj zmena distribúcie dát: napríklad skreslenie podľa kľúča, keď jeden klient alebo región sústreďuje väčšinu záznamov. Na pozadí týchto problémov sa prejavujú aj systémové obmedzenia: zápisy na disk pri nedostatku pamäte, nárast počtu blokovaní pri paralelnej záťaži a spomalenie spôsobené častým automatickým zväčšovaním dátových a logovacích súborov. Všetky tieto faktory spolu vysvetľujú efekt „degradácie“ výkonu.

Na odstránenie problému musí byť prvým krokom vždy diagnostika. Je potrebné získať aktuálny plán vykonania dopytu a zistiť, ktoré operácie spotrebúvajú najviac času a zdrojov. Dôležité je skontrolovať zápisy na disk, konkurenciu o blokovania, využitie pamäte a správanie dátových a logovacích súborov. Porovnanie aktuálneho a historického plánu umožní odhaliť regresiu, napríklad prechod z indexovaného prístupu na plné skenovanie. Takáto analýza umožňuje presne určiť úzke miesto – nefunkčný index, nevhodný plán alebo jednoduchý nedostatok zdrojov.

Nasledujú rýchle opatrenia. Vo väčšine prípadov postačí aktualizovať štatistiky a prestavať indexy, aby sa vrátili správne plány vykonania. Masové operácie aktualizácie alebo mazania je lepšie rozdeliť do dávok po niekoľko tisíc riadkov, aby sa znížilo zaťaženie blokovaniami a logmi. Pri náročných triedeniach a agregáciách pomáha použitie dočasných tabuliek a vytváranie pokrývajúcich indexov práve pre daný krok. Filtre sa odporúča prepisovať do rozsahov, vyhýbať sa funkciám na stĺpcoch. Pre veľké tabuľky sa osvedčuje particionovanie podľa dátumov alebo stavov. Takéto kroky môžu výrazne skrátiť čas vykonania bez radikálnej úpravy kódu.

Dlhodobý výsledok sa dosahuje pravidelnou údržbou a architektonickými zmenami. Je potrebné nastaviť automatickú aktualizáciu štatistík a správu indexov, ako aj presunúť „studené“ dáta do archívnych tabuliek. Pre stabilitu je nutné zaviesť monitoring: upozornenia na nárast času vykonania, zápisy na disk a neočakávané zmeny plánov. Dôležité je aj procesne zabezpečiť, aby každý nový SQL dopyt bol kontrolovaný pred nasadením a testovaný na reálnych objemoch dát. Pri ďalšom raste záťaže sa oplatí zvážiť architektonické opatrenia: inkrementálne načítanie namiesto plného prepočtu, staging zóny na prípravu dát alebo presun historických vrstiev do samostatného úložiska. Takýto prístup umožňuje nielen odstrániť aktuálnu degradáciu, ale aj vybudovať stabilnú a predvídateľnú prevádzku systému do budúcnosti.
