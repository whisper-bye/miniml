open Utils

type expr =
  | Int of int
  | Bool of bool
  | Unit
  | Var of name
  | Binop of name * expr * expr
  | Let of (name * Type.t option) * expr * expr
  | Letrec of (name * Type.t) * expr * expr
  | If of expr * expr * expr
  | Fun of (name * Type.t) * expr
  | App of expr * expr

and name = string

let rec desugar = function
  | `Fun (params, body) ->
    begin match params with
    | (param, ty) :: [] ->
      Fun ((param, ty), body)
    | (param, ty) :: params ->
      Fun ((param, ty), desugar (`Fun (params, body)))
    | [] -> Fun (("_", Type.Unit), body)
    end
  | _ -> assert false

let (++) str suf =
  let n = String.length str in
  let m = String.length suf in
  "    " ^ String.sub str 0 (n - m) ^ suf

let rec pprint_expr ~indent = function
  | Int i ->
    printf ~indent "Int: %d\n" i
  | Bool b ->
    printf ~indent "Bool: %s\n" (if b then "true" else "false")
  | Unit ->
    printf ~indent "Unit: ()\n"
  | Var x ->
    printf ~indent "Var: %s\n" x
  | Binop (op, e1, e2) -> (
      printf      ~indent "Binop\n";
      printf      ~indent:(indent ++ "├── ") "(%s)\n" op;
      pprint_expr ~indent:(indent ++ "├── ") e1;
      pprint_expr ~indent:(indent ++ "└── ") e2
    )
  | Let ((x, Some ty), e1, e2) -> (
      printf      ~indent "Let\n";
      printf      ~indent:(indent ++ "├── ") "%s: %s\n" x (Type.string_of_type ty);
      pprint_expr ~indent:(indent ++ "├── ") e1;
      pprint_expr ~indent:(indent ++ "└── ") e2
    )
  | Let ((x, None), e1, e2) -> (
      printf      ~indent "Let\n";
      printf      ~indent:(indent ++ "├── ") "%s\n" x;
      pprint_expr ~indent:(indent ++ "├── ") e1;
      pprint_expr ~indent:(indent ++ "└── ") e2
    )
  | Letrec ((x, ty), e1, e2) -> (
      printf      ~indent "Letrec\n";
      printf      ~indent:(indent ++ "├── ") "%s: %s\n" x (Type.string_of_type ty);
      pprint_expr ~indent:(indent ++ "├── ") e1;
      pprint_expr ~indent:(indent ++ "└── ") e2
    )
  | If (e1, e2, e3) -> (
      printf      ~indent "If\n";
      pprint_expr ~indent:(indent ++ "├── ") e1;
      pprint_expr ~indent:(indent ++ "├── ") e2;
      pprint_expr ~indent:(indent ++ "└── ") e3
    )
  | Fun ((x, ty), e) -> (
      printf      ~indent "Fun\n";
      printf      ~indent:(indent ++ "├── ") "%s: %s\n" x (Type.string_of_type ty);
      pprint_expr ~indent:(indent ++ "└── ") e
    )
  | App (e1, e2) -> (
      printf      ~indent "App\n";
      pprint_expr ~indent:(indent ++ "├── ") e1;
      pprint_expr ~indent:(indent ++ "└── ") e2
    )

let pprint_prog expr =
  print_endline "Program";
  pprint_expr ~indent:"└── " expr
