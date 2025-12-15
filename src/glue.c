/**
 * Random files to make stuff work
 */
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <stdint.h>
#include <libdragon.h>

int filesize( FILE *pFile )
{
    fseek( pFile, 0, SEEK_END );
    int lSize = ftell( pFile );
    rewind( pFile );

    return lSize;
}

sprite_t *read_sprite( const char * const spritename )
{
    FILE *fp = fopen( spritename, "r" );

    if( fp )
    {
        sprite_t *sp = malloc( filesize( fp ) );
        fread( sp, 1, filesize( fp ), fp );
        fclose( fp );

        return sp;
    }
    else
    {
        return 0;
    }
}

