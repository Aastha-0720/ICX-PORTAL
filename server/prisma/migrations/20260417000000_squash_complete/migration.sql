-- Squashed migration: complete schema from scratch

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('superadmin', 'admin', 'supplier', 'broker', 'customer', 'reader', 'viewer', 'subordinate');

-- CreateEnum
CREATE TYPE "KycStatus" AS ENUM ('submitted', 'approved');

-- CreateEnum
CREATE TYPE "ListingType" AS ENUM ('DC_SITE', 'GPU_CLUSTER');

-- CreateEnum
CREATE TYPE "ListingStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'IN_REVIEW', 'REVISION_REQUESTED', 'RESUBMITTED', 'APPROVED', 'REJECTED', 'MATCHED', 'CLOSED', 'AVAILABLE', 'RESERVED', 'SOLD', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "OrgType" AS ENUM ('SUPPLIER', 'BROKER', 'CUSTOMER');

-- CreateEnum
CREATE TYPE "OrgStatus" AS ENUM ('PENDING', 'SUBMITTED', 'APPROVED', 'REJECTED', 'REVISION_REQUESTED');

-- CreateTable
CREATE TABLE "Organization" (
    "id" UUID NOT NULL,
    "type" "OrgType" NOT NULL,
    "status" "OrgStatus" NOT NULL DEFAULT 'PENDING',
    "vendor_type" TEXT,
    "mandate_status" TEXT,
    "nda_required" BOOLEAN NOT NULL DEFAULT false,
    "nda_signed" BOOLEAN NOT NULL DEFAULT false,
    "contact_email" TEXT NOT NULL,
    "contact_number" TEXT,
    "company_name" TEXT,
    "company_type" TEXT,
    "jurisdiction" TEXT,
    "industry_sector" TEXT,
    "tax_vat_number" TEXT,
    "company_address" TEXT,
    "website" TEXT,
    "auth_signatory_name" TEXT,
    "auth_signatory_title" TEXT,
    "billing_contact_name" TEXT,
    "billing_contact_email" TEXT,
    "primary_use_cases" TEXT[],
    "location_preferences" TEXT[],
    "sovereignty_reqs" TEXT[],
    "compliance_reqs" TEXT[],
    "budget_range" TEXT,
    "urgency" TEXT,
    "flagged_fields" TEXT[],
    "field_comments" JSONB DEFAULT '{}',
    "reviewed_by" UUID,
    "approved_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Organization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "name" TEXT,
    "email" TEXT NOT NULL,
    "role" "Role" NOT NULL,
    "kyc_status" "KycStatus",
    "organization_id" UUID,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Listing" (
    "id" UUID NOT NULL,
    "supplier_id" UUID NOT NULL,
    "organization_id" UUID,
    "type" "ListingType" NOT NULL DEFAULT 'GPU_CLUSTER',
    "data_center_name" TEXT,
    "country" TEXT,
    "state" TEXT,
    "city" TEXT,
    "total_units" INTEGER NOT NULL DEFAULT 0,
    "booked_units" INTEGER NOT NULL DEFAULT 0,
    "available_units" INTEGER NOT NULL DEFAULT 0,
    "total_mw" DOUBLE PRECISION,
    "available_mw" DOUBLE PRECISION,
    "price" DOUBLE PRECISION,
    "currency" TEXT DEFAULT 'USD',
    "status" "ListingStatus" NOT NULL DEFAULT 'DRAFT',
    "specifications" JSONB DEFAULT '{}',
    "metadata" JSONB DEFAULT '{}',
    "contract_duration" TEXT,
    "archived_at" TIMESTAMP(3),
    "archive_reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Listing_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DcSite" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "site_name" TEXT NOT NULL,
    "specifications" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DcSite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DcPhasingSchedule" (
    "id" UUID NOT NULL,
    "site_id" UUID NOT NULL,
    "month" TIMESTAMP(3) NOT NULL,
    "it_load_mw" DOUBLE PRECISION,
    "cumulative_it_load_mw" DOUBLE PRECISION,
    "scope_of_works" TEXT,
    "estimated_capex_musd" DOUBLE PRECISION,
    "phase" TEXT,
    "min_lease_duration_yrs" INTEGER,
    "nrc_request_musd" DOUBLE PRECISION,
    "initial_deposit_musd" DOUBLE PRECISION,
    "mrc_request_per_kw" DOUBLE PRECISION,
    "mrc_inclusions" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DcPhasingSchedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DcDocument" (
    "id" UUID NOT NULL,
    "site_id" UUID NOT NULL,
    "document_type" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "file_url" TEXT NOT NULL,
    "file_size" INTEGER NOT NULL,
    "mime_type" TEXT NOT NULL,
    "uploaded_by" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DcDocument_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ListingDocument" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "document_type" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "file_url" TEXT NOT NULL,
    "file_size" INTEGER NOT NULL,
    "mime_type" TEXT NOT NULL,
    "uploaded_by" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ListingDocument_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reservation" (
    "id" UUID NOT NULL,
    "listing_id" UUID NOT NULL,
    "customer_id" UUID NOT NULL,
    "reserved_units" INTEGER NOT NULL,
    "start_date" TIMESTAMP(3) NOT NULL,
    "end_date" TIMESTAMP(3) NOT NULL,
    "status" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Reservation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT,
    "link" TEXT,
    "metadata" JSONB,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "sent_via" TEXT[] DEFAULT ARRAY['in-app']::TEXT[],
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "action" TEXT NOT NULL,
    "target_model" TEXT,
    "target_id" TEXT,
    "changes" JSONB,
    "ip_address" TEXT,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Otp" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "purpose" TEXT NOT NULL DEFAULT 'login',
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Otp_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ReportTemplate" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "report_type" TEXT NOT NULL DEFAULT 'DC_LISTINGS',
    "selected_fields" JSONB NOT NULL,
    "filters" JSONB NOT NULL,
    "sort_by" TEXT,
    "sort_direction" TEXT,
    "group_by" TEXT,
    "export_format" TEXT,
    "is_favorite" BOOLEAN NOT NULL DEFAULT false,
    "usage_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ReportTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QueueItem" (
    "id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "reference_id" UUID NOT NULL,
    "reference_model" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'NEW',
    "priority" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "QueueItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable (many-to-many QueueItem <-> User)
CREATE TABLE "_AssignedAdmins" (
    "A" UUID NOT NULL,
    "B" UUID NOT NULL
);

-- CreateTable
CREATE TABLE "BrokerDcCompany" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "legal_entity" TEXT NOT NULL,
    "office_address" TEXT NOT NULL,
    "country_of_incorp" TEXT NOT NULL,
    "contact_name" TEXT,
    "contact_email" TEXT,
    "contact_mobile" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BrokerDcCompany_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TeamInvite" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "inviter_id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'subordinate',
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "token" TEXT UNIQUE,
    "expires_at" TIMESTAMP(3),
    "accepted_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TeamInvite_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Inquiry" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "organization_id" UUID,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'NEW',
    "specifications" JSONB DEFAULT '{}',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Inquiry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Archive" (
    "id" UUID NOT NULL,
    "target_model" TEXT NOT NULL,
    "target_id" UUID NOT NULL,
    "organization_id" UUID,
    "reason" TEXT,
    "reason_text" TEXT,
    "archived_by" UUID,
    "archived_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "restored_at" TIMESTAMP(3),
    "restored_by" UUID,
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "Archive_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_organization_id_idx" ON "User"("organization_id");

-- CreateIndex
CREATE INDEX "Listing_supplier_id_idx" ON "Listing"("supplier_id");

-- CreateIndex
CREATE INDEX "Listing_organization_id_idx" ON "Listing"("organization_id");

-- CreateIndex
CREATE INDEX "Listing_status_idx" ON "Listing"("status");

-- CreateIndex
CREATE INDEX "Listing_type_idx" ON "Listing"("type");

-- CreateIndex
CREATE INDEX "DcSite_listing_id_idx" ON "DcSite"("listing_id");

-- CreateIndex
CREATE INDEX "DcPhasingSchedule_site_id_idx" ON "DcPhasingSchedule"("site_id");

-- CreateIndex
CREATE INDEX "DcDocument_site_id_idx" ON "DcDocument"("site_id");

-- CreateIndex
CREATE INDEX "ListingDocument_listing_id_idx" ON "ListingDocument"("listing_id");

-- CreateIndex
CREATE INDEX "Otp_email_idx" ON "Otp"("email");

-- CreateIndex
CREATE INDEX "QueueItem_reference_id_idx" ON "QueueItem"("reference_id");

-- CreateIndex
CREATE INDEX "BrokerDcCompany_organization_id_idx" ON "BrokerDcCompany"("organization_id");

-- CreateIndex
CREATE INDEX "TeamInvite_organization_id_idx" ON "TeamInvite"("organization_id");

-- CreateIndex
CREATE INDEX "TeamInvite_email_idx" ON "TeamInvite"("email");

-- CreateIndex
CREATE INDEX "Inquiry_user_id_idx" ON "Inquiry"("user_id");

-- CreateIndex
CREATE INDEX "Inquiry_organization_id_idx" ON "Inquiry"("organization_id");

-- CreateIndex
CREATE INDEX "Archive_target_id_idx" ON "Archive"("target_id");

-- CreateIndex
CREATE INDEX "Archive_organization_id_idx" ON "Archive"("organization_id");

-- CreateIndex
CREATE UNIQUE INDEX "_AssignedAdmins_AB_unique" ON "_AssignedAdmins"("A", "B");

-- CreateIndex
CREATE INDEX "_AssignedAdmins_B_index" ON "_AssignedAdmins"("B");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DcSite" ADD CONSTRAINT "DcSite_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "Listing"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DcPhasingSchedule" ADD CONSTRAINT "DcPhasingSchedule_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "DcSite"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DcDocument" ADD CONSTRAINT "DcDocument_site_id_fkey" FOREIGN KEY ("site_id") REFERENCES "DcSite"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ListingDocument" ADD CONSTRAINT "ListingDocument_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "Listing"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_listing_id_fkey" FOREIGN KEY ("listing_id") REFERENCES "Listing"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReportTemplate" ADD CONSTRAINT "ReportTemplate_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BrokerDcCompany" ADD CONSTRAINT "BrokerDcCompany_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "Organization"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamInvite" ADD CONSTRAINT "TeamInvite_inviter_id_fkey" FOREIGN KEY ("inviter_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TeamInvite" ADD CONSTRAINT "TeamInvite_email_fkey" FOREIGN KEY ("email") REFERENCES "User"("email") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Inquiry" ADD CONSTRAINT "Inquiry_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Inquiry" ADD CONSTRAINT "Inquiry_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Archive" ADD CONSTRAINT "Archive_archived_by_fkey" FOREIGN KEY ("archived_by") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Archive" ADD CONSTRAINT "Archive_restored_by_fkey" FOREIGN KEY ("restored_by") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_AssignedAdmins" ADD CONSTRAINT "_AssignedAdmins_A_fkey" FOREIGN KEY ("A") REFERENCES "QueueItem"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_AssignedAdmins" ADD CONSTRAINT "_AssignedAdmins_B_fkey" FOREIGN KEY ("B") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
