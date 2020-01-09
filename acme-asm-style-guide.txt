All_names_use_underscore_instead_of_camel_case
Sorry_camel_peeps

;****************************************************************************
;   Section
;****************************************************************************
; Section comments should precede most major portions of a file.

;****************************************************************************
; Macros_have_a_header_comment
; Briefly describing their purpose
;****************************************************************************
; INPUTS:   .each_variable      Gets a description
;           [.optional_params]  When defining multiple macros with the same name,
;                               optional params are in brackets. They work like
;                               optional params in C++17 - to specify a particular
;                               param you must specify all previous ones as well.
;           [.another = 2]      Another optional param, but with a default value
;****************************************************************************
; MODIFIES: .A, .X, .Y, And_variables_as_appropriate
;****************************************************************************
; OUTPUTS: .A, .X, .Y, and_variables_as_appropiate
;****************************************************************************

!macro MACROS_ARE_ALWAYS_UPPER_CASE {}

!define DEFINES_ARE_ALSO_UPPER_CASE=1

Constants_and_Variables_not_starting_with_at-sign_or_dot=$9F20
Are_alway_considered_to_be_global=$9F21
And_should_start_with_capital_letter !byte $ff

;****************************************************************************
; Functions_also_get_a_header_comment
; Briefly describing their purpose
;****************************************************************************
; INPUTS:   .A   Register or Variable_as_appropriate
;****************************************************************************
; MODIFIES: .A, .X, .Y, And_variables_as_appropriate
;****************************************************************************
; OUTPUTS: .A, .X, .Y, and_variables_as_appropiate
;****************************************************************************
function_names_are_lower_case:

    jsr     ; Single-line, inline comments start on a convenient tab indentation

    ; Multi-line, comments within executable code prefers to start
    ; on the same tab indentation as instructions. This is to differentiate
    ; from comments outside of an executable context.

loop:
    Any
    loops
    that
    are
    more
    than
    12
    lines
    need
    a
    real
    label
    jmp loop

-   short
    loops
    dont
    jmp -

@local_labels_in_functions_are_prefexed_with_at-sign:
	; @labels are not accessible outside surrounding
	; non-local labels
	; See:
	; https://github.com/meonwax/acme/blob/99fae48b1fc44a3fc25b84d51857d36c1d6967e1/docs/QuickRef.txt#L421

.local_labels_in_macros_are_prefixed_with_dot
	; .labels in macros are not accessible outside the macro

;****************************************************************************
; Data
;****************************************************************************
Constant_data_variables_go_into_their_own_block:
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;****************************************************************************
; Variables
;****************************************************************************
Global_variable_labels_begin_with_upper_case: !byte $00

Large_blocks_of_data_begin_on_the_following_line:
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    !byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; Avoid putting more than 16 bytes on a single line, for readability.
