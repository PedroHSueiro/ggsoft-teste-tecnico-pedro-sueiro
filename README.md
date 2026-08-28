# Teste técnico de animação

## Processo escolhido - Spine:

Para a construção desse teste, o personagem de referência foi recortado, reutilizando as partes simétricas, e animado por meio do Spine com a criação de uma mesh para seus membros, uma cadeia de bones básica e suavizações nas transições de movimento. A implementação lógica foi mais complicada, precisando de classes utilitárias para o carregamento da textura e manipulação de arquivos, além da renderização manual, que foi feita por meio dos triângulos da mesh do personagem. Por fim, o update da animação foi executado utilizando a base do timer disponibilizado na demo do projeto.