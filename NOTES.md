Major components/features:
  * Finder methods
  * Attributes
  * Queueing
  * Generating requests
  * Handling responses
  * URL generation
  * Mapping responses to resources
    * Mapping attributes
  * Associations
  * Logging
  * Mocking

Goals of next version:
  * Remove reliance on Thread.current
    * railtie?
    * request?
    * requests are local to a request (if a request object is available)
  * Easier method of setting options that are request-wide
    * currently uses an attribute on Thread.current
  * Allow user to set scope of queue (request-level, application-level,
    thread-level, etc.)
  * Remove reliance on modules -- use separate objects
  * Redefine some of the more obtuse options (e.g., :using)
  * Class methods on resources should be persisted to relations
  * Add support for scopes
  * local_attributes (attributes that are set via to_json/as_json, but
    are not actually part of the server's response)
  * Allow queueing to be disabled per-request/per-model
  * Allow access to attributes returned from the server for which a map
    does not exist
  * Fix issue where two a Resource#where that relies on data from a
    different resource can cause it to prematurely process based on
    previous calls to #where
  * Fix issue where Relation does not respect .from= setting
  * Move queueing logic into a separate module/gem?
