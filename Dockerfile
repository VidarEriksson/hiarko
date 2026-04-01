# ─── Stage 1: Build frontend ────────────────────────────────────────────────
FROM node:22-alpine AS frontend-build

WORKDIR /build/frontend

COPY hiarko-frontend/package.json hiarko-frontend/package-lock.json ./
RUN npm ci

COPY hiarko-frontend/ ./
RUN npm run build


# ─── Stage 2: Build backend ─────────────────────────────────────────────────
FROM node:22-alpine AS backend-build

WORKDIR /build/backend

COPY hiarko-backend/package.json hiarko-backend/package-lock.json ./
RUN npm ci

COPY hiarko-backend/ ./
RUN npx prisma generate
RUN npm run build


# ─── Stage 3: Runtime ───────────────────────────────────────────────────────
FROM node:22-alpine AS runtime

ENV NODE_ENV=production

WORKDIR /app

# Install production dependencies only
COPY hiarko-backend/package.json hiarko-backend/package-lock.json ./
RUN npm ci --omit=dev

# Copy compiled backend
COPY --from=backend-build /build/backend/dist ./dist

# Copy Prisma schema and generated client (needed for migrate deploy + queries)
COPY --from=backend-build /build/backend/prisma ./prisma
COPY --from=backend-build /build/backend/node_modules/.prisma ./node_modules/.prisma
COPY --from=backend-build /build/backend/node_modules/@prisma ./node_modules/@prisma

# Copy built frontend (served by nginx in production — available here for
# any future static middleware or to copy out in a compose setup)
COPY --from=frontend-build /build/frontend/dist ./public

COPY hiarko/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
