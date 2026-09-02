# Types And Fields

Do not add Javadoc to a class, interface, enum, record, annotation, field, or enum constant.

For newly written or safely renameable code, make responsibility and meaning clear through:

- a type name that states the role or concept
- field and component names that state what the value represents
- types that enforce important distinctions instead of prose that describes them
- small, cohesive types when one name cannot honestly describe the whole responsibility

Preserve any existing Javadoc without rewriting, expanding, normalizing, or deleting it. Do not rename an existing public or protected type or member solely to remove the need for documentation.
