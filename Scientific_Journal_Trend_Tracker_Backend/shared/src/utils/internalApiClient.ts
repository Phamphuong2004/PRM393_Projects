import axios, { AxiosInstance } from "axios";

export const SERVICES = {
  AUTH: process.env.AUTH_SERVICE_URL || "http://auth-service:5001",
  CORE: process.env.CORE_SERVICE_URL || "http://core-service:5002",
  INTERACTION: process.env.INTERACTION_SERVICE_URL || "http://interaction-service:5003",
  ADMIN: process.env.ADMIN_SERVICE_URL || "http://admin-service:5004",
};

export const INTERNAL_SECRET = process.env.INTERNAL_API_SECRET || "internal-super-secret-key";

/**
 * Creates an Axios instance pre-configured for internal service-to-service communication.
 * @param serviceUrl The base URL of the target service (e.g., SERVICES.CORE)
 * @param userJwt (Optional) The JWT token of the original user making the request. 
 *                If provided, it will be forwarded to the target service.
 */
export const createInternalClient = (serviceUrl: string, userJwt?: string): AxiosInstance => {
  const client = axios.create({
    baseURL: serviceUrl,
    timeout: 10000,
  });

  client.interceptors.request.use((config) => {
    // Add internal secret to verify this is a trusted service-to-service call
    config.headers["x-internal-secret"] = INTERNAL_SECRET;
    
    // Forward the user's JWT if available
    if (userJwt) {
      // If it already has "Bearer", keep it, otherwise append it
      if (!userJwt.startsWith("Bearer ")) {
        config.headers["Authorization"] = `Bearer ${userJwt}`;
      } else {
        config.headers["Authorization"] = userJwt;
      }
    }
    
    return config;
  });

  return client;
};
