(** AKTSP projekt
    Regulaaravaldiste ekvivalentsus
    Autor: Rainer Talvik *)

(** Tugineb AKTSP 2023/24 15. praktikumi regulaaravaldiste moodulile. *)
open Regex

(** Regulaaravaldiste normaalkujule viimise funktsioon. 
    Siin pole Choice juures osaline järjestus korrektselt defineeritud, 
      kuid see oleks oluline nat.arvude puhul, nagu paberis kirjas. *)
let rec norm (regexp: t): t =
  match regexp with
  | Empty -> Empty
  | Eps -> Eps
  | Char _ -> regexp
  | Star a -> Star (norm a)
  | Concat (r, Empty)
  | Concat (Empty, r) -> Empty
  | Concat (r, Eps)
  | Concat (Eps, r) -> r
  | Concat (l, r) -> Concat (norm l, norm r)
  | Choice (Empty, r)
  | Choice (r, Empty) -> r
  | Choice (r, r') when equal r r' -> r
  | Choice (l, r) -> Choice (norm l, norm r)

(** Regulaaravaldises tühja sõne sisaldumise funktsioon.
    Identne 15. praktikumi funktsiooniga matches_eps. *)
let final = Regex.Brzozowski.matches_eps

(** Regulaaravaldiste tuletiste võtmise funktsioon.
    Garanteerib normaalkujul tulemuse.
    Identne 15. praktikumi funktsiooniga derive. *)
let derive (regexp: t) (symbol: char) = Regex.Brzozowski.derive (norm regexp) symbol

(** Aatomite defineerimiseks vajame regulaaravaldiste hulkade implementatsiooni.
    Siit edasi tuleb märkida Regex.t (kui üldse märkida), kuna muidu tekib konflikt CharSet.t-ga. *)
module CharSet = Set.Make (Char)
open CharSet

(** Regulaaravaldistes sisalduvate sümbolite leidmise funktsioon.
    Alguses normeerime, seejärel töötleme.
    Hetkeseisuga ma ei kasuta seda lõplikus programmis (kuna meil on addAtoms). 
    Mõttekam oleks mitte topelttööd teha, muuta üheks. *)
let rec atoms (regexp: Regex.t): CharSet.t =
  match norm regexp with
  | Empty -> CharSet.empty
  | Eps -> CharSet.empty
  | Char c -> CharSet.singleton c
  | Choice (r, s) -> CharSet.union (atoms r) (atoms s)
  | Concat (r, s) -> CharSet.union (atoms r) (atoms s)
  | Star r -> atoms r

(** Leiame rekursiivselt, kas funktsioon c termineerub.
    Kui termineerub, siis saame leida püsipunkti ja kasutada edaspidi funktsioonis closure.
    * b - rekursiooni tingimusfunktsioon - kui kehtib, siis lähme kihi võrra sügavamale;
    * c - funktsioon regulaaravaldise teisendamiseks;
    * s - ette antud regulaaravaldis. *)
let rec whileOption b c s =
  if b s then 
    whileOption b c (c s) 
  else 
    Some s

(** Testfunktsioon, mis kontrollib, kas argumendiks antud paaride listi ws esimese paari elemendid jõuavad tühisõneni (või korraga ei jõua).
    Kasutame testfunktsioonina funktsioonis closure. *)
let test = function
  | ([], _) -> false
  | (p, q) :: _, _ -> final p = final q

(** Sammufunktsioon, mis võtab ws pea (r, s),
    lisab pea hulka ps' (koopia ps-ist + (r, s)),
    käivitab tuletise funktsiooni üle r, üle s, võttes tuletise kõikide aatomite järgi,
    filtreerib saadud tuletistest välja kõik väärtused, mis ei kuulu hulkade ps' ja ws ühendisse.
    Tagastatakse töödeldud listid.
    Hetkel tekitab väga palju korduvaid elemente akumulaatorisse.
    Iseenesest saaks need välja filtreerida.
    *)
let step (atomList: elt list) (ws, ps) = 
  let (r, s) = List.hd ws in
  let ps' = (r, s) :: ps in
  let succs = List.map (fun a -> (derive r a, derive s a)) atomList in
  let new_pairs = List.filter (fun p -> not (List.mem p ps' || List.mem p ws)) succs in
  (new_pairs @ List.tl ws, ps')

(** Käivitab testi, kuni tingimus kehtib. Jõuab sulundini.
    Kuna step teeb palju samme siis ka closure teeb pisut pikalt tööd. *)
let closure (atomList: elt list) =
  whileOption test (step atomList)

(** Lisab ette antud regulaaravaldise aatomid ette antud listi. *)
let rec addAtoms (regexp: Regex.t) (regexpList: elt list): elt list =
  match norm regexp with
  | Empty -> regexpList
  | Eps -> regexpList
  | Choice (r, s) -> addAtoms s (addAtoms r regexpList)
  | Concat (r, s) -> addAtoms s (addAtoms r regexpList)
  | Star r -> addAtoms r regexpList
  | Char c -> 
    let searchResult = List.mem c regexpList in
    match searchResult with
    | false -> c :: regexpList
    | _ -> regexpList

(** Kahe regulaaravaldise ekvivalentsuse kontrollija.
    Hetkel ei tööta, kui vastus on tõene ning mõlemad regulaaravaldised koosnevad sisemisest valikuoperatsioonist ja välimisest tärnoperatsioonist.
    Näiteks "(a|b)*" ja "(b|a)*" võrreldes jääb programm lõputult tööle.
    Viga tuleb ilmselt checkEquiv meetodist endast, sest funktsioonihaaval (kuni closure'ini, k.a) katsetades programm termineerus,
    Kuid checkEquiv sel erijuhul ei tööta.
    Kahjuks ei jõudnud enne tähtaega individuaalselt korda saada ): Oleksin võinud muidugi abi küsida. *)
let checkEquiv (r: Regex.t) (s: Regex.t): bool =
  match closure (addAtoms r (addAtoms s [])) ([(norm r, norm s)], []) with 
  | Some ([], _) -> true
  | _ -> false

(** Kontrollib, kas ühe regulaaravaldise keel sisaldub teises.
    Hetkel poolik ja ei tööta - kui oleks võimalik kuidagi regulaaravaldise keelest ühisosa võtta, jõuaksin lahenduseni.
    Kommentaaridena on märgitud idee, kus võtan tuletisi, kuni jõuan ühega tühisõneni (?), aga ei mõelnud tuletisega lahendust samuti välja. *)
let regexpSubset (r: Regex.t) (s: Regex.t): bool =
  let intersection = Eps (* Siia käib midagi muud! *) in
  checkEquiv intersection r || checkEquiv intersection s