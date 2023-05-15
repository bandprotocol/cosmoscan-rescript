/** @returns {Promise<import('jest').Config>} */
module.exports = async () => {
  return {
    testRunner: 'jest-jasmine2',
    verbose: true,
  }
}
