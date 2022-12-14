'use strict'

module.exports = async function (fastify, opts) {
  /**
   * @type {import('fastify').RouteShorthandOptions}
   * @const
   */
  const postOptions = {
    schema: {
      body: {
        type: 'object',
        properties: {
          diceFaces: { type: 'number' }
        }
      }
    }
  }
  fastify.put('/:userId', postOptions, async function (request, reply) {
    request.log.info(`Saving settings for user ${request.params.userId}`);
    await fastify.db.saveSettings(request.params.userId, request.body);
    reply.code(204);
  })

  fastify.get('/:userId', async function (request, reply) {
    const settings = await fastify.db.getSettings(request.params.userId);
    if (settings) {
      return settings;
    }
    reply.code(404);
  })
}
