#pragma once
#include "./src/man/entity.c"


//Declarations
void sys_anim_init();
void sys_anim_update(TEntity *entity);

void sys_anim_init(){}
void sys_anim_update(TEntity *entity){
    if (entity->andando==0){
        entity->andando=1;
    }else{
        entity->andando=0;
    } 
}
