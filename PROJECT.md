# skill-harness-scaffold
Name: skill-harness
 
Description: Skill para Claude Code que genera automáticamente la estructura base de un harness multi-agente en cualquier proyecto nuevo.

## Estructura del proyecto

skill-harness-scaffold/
├── SKILL.md
├── references/
│   └── templates/
│       ├── CLAUDE.md.tmpl
│       ├── AGENTS.md.tmpl
│       ├── CHECKPOINTS.md.tmpl
│       ├── feature_list.json.tmpl
│       └── agents/
│           ├── leader.md.tmpl
│           ├── implementer.md.tmpl
│           └── reviewer.md.tmpl
└── examples/
    ├── project_simple/
    └── project_data/

## Qué hace esta Skill

Cuando Claude Code detecta que el usuario quiere crear un proyecto nuevo o inicializar un harness, genera todos los ficheros de la estructura anterior con contenido funcional basado en las plantillas de `references/templates/`.

## Lo que NO hace

No personaliza el contenido según el dominio del proyecto. Genera siempre la misma estructura base lista para personalizar manualmente.
EOF