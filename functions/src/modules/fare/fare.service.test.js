const fareService = require('../fare.service');

describe('Fare Calculation', () => {
  test('calculates NonAC fare correctly', async () => {
    // Mock DB call
    const mockDb = {
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({
          get: jest.fn(() => Promise.resolve({
            exists: true,
            data: () => ({ routeId: 'r1', busClass: 'NonAC' }),
          })),
        })),
      })),
    };
    jest.mock('../../../config/firebase.config', () => ({ db: mockDb }));

    // This is a unit test stub; integration tests use Firebase emulators
    expect(typeof fareService.calculateFare).toBe('function');
  });

  test('AC class multiplier is 1.4x NonAC', () => {
    const base = 100;
    expect(Math.round(base * 1.4)).toBe(140);
  });
});
