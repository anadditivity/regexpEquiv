# regexpEquiv
TÜ aine "Automaatide, keelte ja translaatorite süvenduspraktikum" projekt

Projekti teema: Regulaaravaldiste ekvivalentsus

Tugineb AKTSP 2023/24 15. praktikumi regulaaravaldiste moodulile (autor Simmo Saan).

Projekti kausta asukoht: src/project. Peamine fail regexpEquiv.ml.
Testfailide asukoht: test/project.

Projekti koodi käivitamine (katsetatud WSL-ga, töötab ka korrektse Linux'i opam installatsiooni korral):

* paki ZIP-fail lahti soovitud asukohta;
* ava soovitud käsurea (shell) programm ning mine lahti pakitud kausta;
* käivita käsk `eval $(opam env)`;
* (VSCode kasutamine) graafilise keskkonna soovil sisestada `code .`;
* projekti automaattestide kasutamine: projektile on koostatud testid, mida saab käivitada käsuga `dune runtest test/project` või, kui on soov projektifaile muuta ning jooksvalt testida, siis `dune runtest -w test/project`;
* projekti interaktiivne kasutamine: sisestada käsk `dune utop`, avada projekt käsuga `open Project.RegexpEquiv;;` ning soovi korral kaust Regex käsuga `open Regex;;` (võimaldab kasutada funktsiooni `parse` ilma moodulit spetsifeerimata, ilma avamata tuleb täpsustada `Regex.parse`).

Näited interaktiivseks kasutamiseks (võetud suuresti testfailist):

    checkEquiv (Regex.parse "a|b") (Regex.parse "b|a");; (* tagastab true*)
    checkEquiv (Regex.parse "ab") (Regex.parse "cd");; (* tagastab false *)
    checkEquiv (Regex.parse "(ka)|(kb)") (Regex.parse "k(a|b)");; (* tagastab true *)
    checkEquiv (Regex.parse "a|b*") (Regex.parse "b|a*");; (* tagastab false *)
    checkEquiv (Regex.parse "((k|r|p|j|v)a)") (Regex.parse "(ka|ra|pa|ja|va)");; (* tagastab true *)
    checkEquiv (Regex.parse "((k|r|p|j|v)a)") (Regex.parse "(ka|ra|pa|ja|v)");; (* tagastab false *)

Ilma Regex.parse-meetodit kasutama tuleks kasutada Regex.t formaati, paar näidet:

    Regex.parse "a|b" -> Choice (Char 'a', Char 'b')
    Regex.parse "a(b|c)d*" -> Concat (Concat (Char 'a', Choice (Char 'b', Char 'c')), Star (Char 'd'))

Puudujäägid:

* ekvivalentsuse kontrollimine ei tööta, kui regulaaravaldiste defineeritud keel on ekvivalentne (peaks tagastama true) ning keel sisaldab sisemist valikuoperatsiooni ja välimist tärnoperatsiooni. See viga oli põhjus, miks esitamine jäi viimasele päevale. Näited all või testfailis välja kommenteeritud märkusega "järgmine jääb lõputult laadima";
* regexpSubset (kas ühe regulaaravaldise keel sisaldub teises) on sisult implementeerimata. Oma peas jõudsin lahenduseni, kus kontrollin regulaaravaldiste R ja S ühisosa ekvivalentsust nii R kui ka S keelega (sest täielikul sisaldumisel on ühisosa võrdne "väiksema" keelega), kuid ma ei mõistnud, milline see implementatsioon võiks olla. Teine variant oleks võtta hulkade vahe ja kontrollida "väiksema" (olgu näiteks R⊆S ning |L(R)|≤|L(S)|, siis vaataksime L(R)∖L(S)) võrdsust tühihulgaga. See annaks soovitud tulemuse, kuid kuna ma ei mõistnud ei ühisosa ega vahe võtmist ilma automaate kasutamata ning ainult checkEquiv kasutades (addAtoms puhul oleks kontroll triviaalne), siis jäi soovitud meetod implementeerimata.
* ebatäielik tüüpide märkimine - arvasin, et funktsioonide päised muutuvad ebavajalikult tekstirohkeks, kui kõik tüübid ära määran. Seetõttu otsustasin vaid lihtsamad tüübid kirja panna. VSCode'i OCaml plugin võimaldas mul siiski tüüpe jälgida
* teste võiks olla rohkem ning need võiksid minna rohkem süvitsi. Mõistan nüüd, kui oluline (ja kurnav) võib olla testide koostamine.

Näiteid mittetermineeruvatest ekvivalentsuse kontrollidest:

    checkEquiv (Regex.parse "(a|b)*") (Regex.parse "(b|a)*");;
    checkEquiv (Regex.parse "((k|r|p|j|v)a)*") (Regex.parse "(ka|ra|pa|ja|va)*");;
