       identification division.
       program-id. helloworld.
       author. alvarodeleon.net.

       environment division.
       configuration section.
       input-output section.

       data division.

       file section.

       working-storage section.

       77 imessage picture x(32) value 'Hello World!!!'.

       procedure division.

           display imessage.

           stop run.
