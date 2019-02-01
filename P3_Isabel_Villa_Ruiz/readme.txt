_____________README P3 _________________________________________________________


En el server_handler.ads, a la hora de pasar el argumento del Máximo de Argumentos,
le paso directamente el ACL.Argument(2)

Max_Length => Integer'Value(ACL.Argument(2)),

A la hora de pasarle un argumento  negativo el programa no tendrá en cuenta este error.
