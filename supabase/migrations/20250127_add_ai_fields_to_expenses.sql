-- Migration: Add AI-related fields to expenses table
-- Created: 2025-01-27
-- Description: Adds fields to track AI parsing confidence, original transcription, and AI suggestions

-- Add AI-related columns to expenses table
ALTER TABLE expenses
ADD COLUMN IF NOT EXISTS ai_confidence DECIMAL(3, 2) DEFAULT NULL,
ADD COLUMN IF NOT EXISTS original_transcription TEXT DEFAULT NULL,
ADD COLUMN IF NOT EXISTS parsed_by_ai BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS ai_model_version VARCHAR(50) DEFAULT NULL;

-- Add comments to explain each field
COMMENT ON COLUMN expenses.ai_confidence IS 'Confidence score (0.00-1.00) from AI parsing';
COMMENT ON COLUMN expenses.original_transcription IS 'Original voice transcription before AI parsing';
COMMENT ON COLUMN expenses.parsed_by_ai IS 'Whether this expense was created via AI parsing';
COMMENT ON COLUMN expenses.ai_model_version IS 'Version of AI model used for parsing (e.g., gemini-1.5-flash)';

-- Create index for querying AI-parsed expenses
CREATE INDEX IF NOT EXISTS idx_expenses_parsed_by_ai ON expenses(parsed_by_ai) WHERE parsed_by_ai = TRUE;

-- Create index for low confidence expenses (for review)
CREATE INDEX IF NOT EXISTS idx_expenses_low_confidence ON expenses(ai_confidence) WHERE ai_confidence IS NOT NULL AND ai_confidence < 0.5;
