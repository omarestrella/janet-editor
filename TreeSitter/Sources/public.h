//
//  parser.h
//  JanetMobile
//
//  Created by Omar Estrella on 6/11/22.
//

#ifdef __cplusplus
extern "C" {
#endif

typedef struct TSLanguage TSLanguage;

// Replace {language} with the name of the parser you are importing.
const TSLanguage *tree_sitter_janet(void);

#ifdef __cplusplus
}
#endif
