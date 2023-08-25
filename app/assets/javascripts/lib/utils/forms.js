import { convertToCamelCase } from '~/lib/utils/text_utility';

export const serializeFormEntries = (entries) =>
  entries.reduce((acc, { name, value }) => Object.assign(acc, { [name]: value }), {});

export const serializeForm = (form) => {
  const fdata = new FormData(form);
  const entries = Array.from(fdata.keys()).map((key) => {
    let val = fdata.getAll(key);
    // Microsoft Edge has a bug in FormData.getAll() that returns an undefined
    // value for each form element that does not match the given key:
    // https://github.com/jimmywarting/FormData/issues/80
    val = val.filter((n) => n);
    return { name: key, value: val.length === 1 ? val[0] : val };
  });

  return serializeFormEntries(entries);
};

/**
 * Like trim but without the error for non-string values.
 *
 * @param {String, Number, Array} - value
 * @returns {String, Number, Array} - the trimmed string or the value if it isn't a string
 */
export const safeTrim = (value) => (typeof value === 'string' ? value.trim() : value);

/**
 * Check if the value provided is empty or not
 *
 * It is being used to check if a form input
 * value has been set or not.
 *
 * @param {String, Number, Array} - Any form value
 * @returns {Boolean} - returns false if a value is set
 *
 * @example
 * returns true for '', '   ', [], null, undefined
 */
export const isEmptyValue = (value) => value == null || safeTrim(value).length === 0;

/**
 * Check if the value has a minimum string length
 *
 * @param {String, Number, Array} - Any form value
 * @param {Number} - minLength
 * @returns {Boolean}
 */
export const hasMinimumLength = (value, minLength) =>
  !isEmptyValue(value) && value.length >= minLength;

/**
 * Checks if the given value can be parsed as an integer as it is (without cutting off decimals etc.)
 *
 * @param {String, Number, Array} - Any form value
 * @returns {Boolean}
 */
export const isParseableAsInteger = (value) =>
  !isEmptyValue(value) && Number.isInteger(Number(safeTrim(value)));

/**
 * Checks if the parsed integer value from the given input is greater than a certain number
 *
 * @param {String, Number, Array} - Any form value
 * @param {Number} - greaterThan
 * @returns {Boolean}
 */
export const isIntegerGreaterThan = (value, greaterThan) =>
  isParseableAsInteger(value) && parseInt(value, 10) > greaterThan;

/**
 * Regexp that matches email structure.
 * Taken from app/models/service_desk_setting.rb custom_email
 */
export const EMAIL_REGEXP = /^[\w\-._]+@[\w\-.]+\.[a-zA-Z]{2,}$/;

/**
 * Checks if the input is a valid email address
 *
 * @param {String} - value
 * @returns {Boolean}
 */
export const isEmail = (value) => EMAIL_REGEXP.test(value);

/**
 * A form object serializer
 *
 * @param {Object} - Form Object
 * @returns {Object} - Serialized Form Object
 *
 * @example
 * Input
 * {"project": {"value": "hello", "state": false}, "username": {"value": "john"}}
 *
 * Returns
 * {"project": "hello", "username": "john"}
 */
export const serializeFormObject = (form) =>
  Object.fromEntries(
    Object.entries(form).reduce((acc, [name, { value }]) => {
      if (!isEmptyValue(value)) {
        acc.push([name, value]);
      }
      return acc;
    }, []),
  );

/**
 * Parse inputs of HTML forms generated by Rails.
 *
 * This can be helpful when mounting Vue components within Rails forms.
 *
 * If called with an HTML element like:
 *
 * ```html
 * <input type="text" placeholder="Email" value="foo@bar.com" name="user[contact_info][email]" id="user_contact_info_email" data-js-name="contactInfoEmail">
 * <input type="text" placeholder="Phone" value="(123) 456-7890" name="user[contact_info][phone]" id="user_contact_info_phone" data-js-name="contactInfoPhone">
 * <input type="checkbox" name="user[interests][]" id="user_interests_vue" value="Vue" checked data-js-name="interests">
 * <input type="checkbox" name="user[interests][]" id="user_interests_graphql" value="GraphQL" data-js-name="interests">
 * ```
 *
 * It will return an object like:
 *
 * ```javascript
 * {
 *   contactInfoEmail: {
 *     name: 'user[contact_info][email]',
 *     id: 'user_contact_info_email',
 *     value: 'foo@bar.com',
 *     placeholder: 'Email',
 *   },
 *   contactInfoPhone: {
 *     name: 'user[contact_info][phone]',
 *     id: 'user_contact_info_phone',
 *     value: '(123) 456-7890',
 *     placeholder: 'Phone',
 *   },
 *   interests: [
 *     {
 *       name: 'user[interests][]',
 *       id: 'user_interests_vue',
 *       value: 'Vue',
 *       checked: true,
 *     },
 *     {
 *       name: 'user[interests][]',
 *       id: 'user_interests_graphql',
 *       value: 'GraphQL',
 *       checked: false,
 *     },
 *   ],
 * }
 * ```
 *
 * @param {HTMLInputElement} mountEl
 * @returns {Object} object with form fields data.
 */
export const parseRailsFormFields = (mountEl) => {
  if (!mountEl) {
    throw new TypeError('`mountEl` argument is required');
  }

  const inputs = mountEl.querySelectorAll('[name]');

  return [...inputs].reduce((accumulator, input) => {
    const fieldName = input.dataset.jsName;

    if (!fieldName) {
      return accumulator;
    }

    const fieldNameCamelCase = convertToCamelCase(fieldName);
    const { id, placeholder, name, value, type, checked, maxLength, pattern } = input;
    const attributes = {
      name,
      id,
      value,
      ...(placeholder && { placeholder }),
      ...(input.hasAttribute('maxlength') && { maxLength }),
      ...(pattern && { pattern }),
    };

    // Store radio buttons and checkboxes as an array so they can be
    // looped through and rendered in Vue
    if (['radio', 'checkbox'].includes(type)) {
      return {
        ...accumulator,
        [fieldNameCamelCase]: [
          ...(accumulator[fieldNameCamelCase] || []),
          { ...attributes, checked },
        ],
      };
    }

    return {
      ...accumulator,
      [fieldNameCamelCase]: attributes,
    };
  }, {});
};