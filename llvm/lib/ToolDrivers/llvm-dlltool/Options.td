include "llvm/Option/OptParser.td"

def m: JoinedOrSeparate<["-"], "m">, HelpText<"Set target machine">;
def m_long : JoinedOrSeparate<["--"], "machine">, Alias<m>;

def l: JoinedOrSeparate<["-"], "l">, HelpText<"Generate an import lib">;
def l_long : JoinedOrSeparate<["--"], "output-lib">, Alias<l>;

def D: JoinedOrSeparate<["-"], "D">, HelpText<"Specify the input DLL Name">;
def D_long : JoinedOrSeparate<["--"], "dllname">, Alias<D>;

def d: JoinedOrSeparate<["-"], "d">, HelpText<"Input .def File">;
def d_long : JoinedOrSeparate<["--"], "input-def">, Alias<d>;

def N: JoinedOrSeparate<["-"], "N">, HelpText<"Input native .def File on ARM64EC">;
def N_long : JoinedOrSeparate<["--"], "input-native-def">, Alias<N>;

def k: Flag<["-"], "k">, HelpText<"Kill @n Symbol from export">;
def k_alias: Flag<["--"], "kill-at">, Alias<k>;

def no_leading_underscore: Flag<["--"], "no-leading-underscore">,
    HelpText<"Don't add leading underscores on symbols">;

def I: JoinedOrSeparate<["-"], "I">, HelpText<"Identify DLL name from import library">;
def I_long : JoinedOrSeparate<["--"], "identify">, Alias<I>;

def identify_strict : Flag<["--"], "identify-strict">, HelpText<"Error out if the --identify option detects more than one DLL">;

//==============================================================================
// The flags below do nothing. They are defined only for dlltool compatibility.
//==============================================================================

def S: JoinedOrSeparate<["-"], "S">, HelpText<"Assembler">;
def S_alias: JoinedOrSeparate<["--"], "as">, Alias<S>;

def f: JoinedOrSeparate<["-"], "f">, HelpText<"Assembler Flags">;
def f_alias: JoinedOrSeparate<["--"], "as-flags">, Alias<f>;

def t: JoinedOrSeparate<["-"], "t">, HelpText<"Prefix for temporary files (ignored)">;
def t_alias: JoinedOrSeparate<["--"], "temp-prefix">, Alias<t>;
