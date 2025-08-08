-- AlterTable
ALTER TABLE "public"."users" ADD COLUMN     "phone_otp" TEXT,
ADD COLUMN     "phone_otp_expires_at" TIMESTAMP(3);
