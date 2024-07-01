export default class FormUtils {
  static buildInput(type, name, value, id, required, options = {}) {
    const input = document.createElement("input");
    input.type = type;
    input.name = name;
    if (id) input.id = id;
    if (value) input.value = value;
    if (required) input.required = required;
    if (options.classes)
      options.classes.forEach((className) => input.classList.add(className));
    if (options.data) this.#createDataAttrs(options.data, input);
    return input;
  }

  // Private functions

  static #createDataAttrs(data, input) {
    Object.keys(data).forEach((entryKey) => {
      const entryObject = data[entryKey];
      Object.keys(entryObject).forEach((propertyKey) => {
        if (propertyKey === "name" && entryObject.name && entryObject.value) {
          input.dataset[entryObject.name] = entryObject.value;
        }
      });
    });
  }
}
