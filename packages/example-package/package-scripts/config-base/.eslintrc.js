// WARNING: this package is a controlled file generated from a template
// do not try to make changes in here, they will be overwritten

// if you want to customize eslint for this package, 
// add rules to config-extras instead

const extras = require('../config-extras/.eslintrc.js');

module.exports = {
	parser: '@typescript-eslint/parser',
	parserOptions: {
		project: require.resolve('../../tsconfig.json'),
	},
	plugins: [
		'@typescript-eslint/eslint-plugin',
		...(extras.plugins || [])
	],
	extends: [
		'eslint:recommended',
    'plugin:@typescript-eslint/eslint-recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
		...(extras.extends || [])
	],
	rules: {
		'@typescript-eslint/no-empty-function': 'warn',
		'@typescript-eslint/no-unsafe-call': 'warn',
		'@typescript-eslint/no-unsafe-return': 'warn',
		'@typescript-eslint/no-unsafe-assignment': 'warn',
		'@typescript-eslint/no-unsafe-member-access': 'warn',
		...(extras.rules || {})
	},
};
