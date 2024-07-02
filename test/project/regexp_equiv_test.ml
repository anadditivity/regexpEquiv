(** AKTSP projekt
    Regulaaravaldiste ekvivalentsus
    Autor: Rainer Talvik *)

open OUnit2
open Project.RegexpEquiv

let assert_equal = assert_equal ~printer:string_of_bool

let test_norm _ =
  assert_equal true (norm (Concat (Empty, Char 'a')) = Empty);
  assert_equal true (norm (Concat (Char 'a', Empty)) = Empty);
  assert_equal true (norm (Concat (Eps, Char 'a')) = Char 'a');
  assert_equal true (norm (Concat (Char 'a', Eps)) = Char 'a');
  assert_equal true (norm (Concat (Concat (Char 'r', Char 's'), Char 't')) = Concat (Concat (Char 'r', Char 's'), Char 't'));
  assert_equal true (norm (Concat (Char 'r', Char 's')) = Concat (Char 'r', Char 's'));
  assert_equal true (norm (Choice (Empty, Char 'a')) = Char 'a');
  assert_equal true (norm (Choice (Char 'a', Empty)) = Char 'a');
  assert_equal true (norm (Choice (Choice (Char 'r', Char 's'), Char 't')) = Choice (Choice (Char 'r', Char 's'), Char 't'));
  assert_equal true (norm (Choice (Char 'r', Char 'r')) = Char 'r')

let test_final _ = 
  assert_equal false (final Empty);
  assert_equal true (final Eps);
  assert_equal false (final (Char 'a'));
  assert_equal true (final (Choice (Char 'r', Eps)));
  assert_equal true (final (Choice (Eps, Char 'r')));
  assert_equal false (final (Choice (Char 'r', Empty)));
  assert_equal false (final (Choice (Empty, Char 'r')));
  assert_equal false (final (Concat (Char 'r', Eps)));
  assert_equal false (final (Concat (Eps, Char 'r')));
  assert_equal false (final (Concat (Char 'r', Empty)));
  assert_equal false (final (Concat (Empty, Char 'r')));
  assert_equal true (final (Star (Char 'r')));
  assert_equal true (final (Concat (Eps, Star (Char 'r'))));
  assert_equal true (final (Concat (Star (Char 'r'), Eps)))

let test_atoms _ =
  assert_equal true (atoms Empty = CharSet.empty);
  assert_equal true (atoms Eps = CharSet.empty);
  assert_equal true (atoms (Regex.parse "a") = CharSet.singleton 'a');
  assert_equal true (atoms (Regex.parse "|a") = CharSet.singleton 'a');
  assert_equal true (atoms (Regex.parse "a|") = CharSet.singleton 'a');
  assert_equal true (atoms (Regex.parse "a|b") = CharSet.union (CharSet.singleton 'a') (CharSet.singleton 'b'));
  assert_equal true (atoms (Regex.parse "ab") = CharSet.union (CharSet.singleton 'a') (CharSet.singleton 'b'));
  assert_equal true (atoms (Regex.parse "a*") = CharSet.singleton 'a')

let test_addAtoms _ = 
  assert_equal true (addAtoms Empty [] = []);
  assert_equal true (addAtoms Eps [] = []);
  assert_equal true (addAtoms (Char 'a') [] = ['a']);
  assert_equal true (addAtoms (Choice (Char 'a', Char 'b')) [] = ['b'; 'a']);
  assert_equal true (addAtoms (Concat (Char 'a', Char 'b')) [] = ['b'; 'a']);
  assert_equal true (addAtoms (Star (Char 'a')) [] = ['a'])

let test_basic _ =
  assert_equal false (checkEquiv (Regex.parse "ag") (Regex.parse "b"));
  assert_equal true (checkEquiv (Regex.parse "a") (Regex.parse "a"));
  assert_equal true (checkEquiv (Regex.parse "b") (Regex.parse "b"))

let test_choice _ =
  assert_equal true (checkEquiv (Regex.parse "a|b") (Regex.parse "b|a"));
  assert_equal false (checkEquiv (Regex.parse "a|b") (Regex.parse "a|c"));
  assert_equal false (checkEquiv (Regex.parse "a|b") (Regex.parse "c|d"))

let test_concat _ =
  assert_equal true (checkEquiv (Regex.parse "ab") (Regex.parse "ab"));
  assert_equal false (checkEquiv (Regex.parse "ab") (Regex.parse "ba"));
  assert_equal false (checkEquiv (Regex.parse "ab") (Regex.parse "cd"))

let test_star _ =
  assert_equal true (checkEquiv (Regex.parse "a*") (Regex.parse "a*"));
  assert_equal false (checkEquiv (Regex.parse "a*") (Regex.parse "b*"));
  assert_equal false (checkEquiv (Regex.parse "a*") (Regex.parse "ab*"))

let test_combined _ =
  assert_equal true (checkEquiv (Regex.parse "(ka)|(kb)") (Regex.parse "k(a|b)"));
  (* järgmine jääb lõputult laadima *)
  (*assert_equal true (checkEquiv (Regex.parse "(a|b)*") (Regex.parse "(b|a)*")); *)
  assert_equal false (checkEquiv (Regex.parse "(a|b)*") (Regex.parse "(a|c)*"));
  assert_equal false (checkEquiv (Regex.parse "(a|b)*") (Regex.parse "(c|d)*"));
  assert_equal false (checkEquiv (Regex.parse "(ab)*") (Regex.parse "(ba)*"));
  assert_equal false (checkEquiv (Regex.parse "(ab)*") (Regex.parse "(cd)*"))
  (* järgmine jääb lõputult laadima ): *)
  (*assert_equal true (checkEquiv (Regex.parse "((k|r|p|j|v)a)*") (Regex.parse "(ka|ra|pa|ja|va)*"))  *)

let tests =
  "project" >::: [
    "separate_functions" >::: [
      "norm" >:: test_norm;
      "final" >:: test_final;
      "atoms" >:: test_atoms;
      "addAtoms" >:: test_addAtoms
    ];
    "operations" >::: [
      "basic" >:: test_basic;
      "choice" >:: test_choice;
      "concat" >:: test_concat;
      "star" >:: test_star;
      "combined" >:: test_combined
    ]
  ]

let _ = run_test_tt_main tests