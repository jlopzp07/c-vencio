-- Migration: Create AI expense suggestions table
-- Created: 2025-01-27
-- Description: Table to store AI-generated expense suggestions and insights

-- Create ai_expense_suggestions table
CREATE TABLE IF NOT EXISTS ai_expense_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    suggestion_type VARCHAR(50) NOT NULL, -- 'recurring', 'budget_alert', 'maintenance_due', 'cost_optimization'
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    confidence DECIMAL(3, 2) DEFAULT NULL,
    metadata JSONB DEFAULT '{}', -- Additional data specific to suggestion type
    is_dismissed BOOLEAN DEFAULT FALSE,
    dismissed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Add comments
COMMENT ON TABLE ai_expense_suggestions IS 'AI-generated suggestions and insights for vehicle expenses';
COMMENT ON COLUMN ai_expense_suggestions.suggestion_type IS 'Type of suggestion: recurring, budget_alert, maintenance_due, cost_optimization';
COMMENT ON COLUMN ai_expense_suggestions.priority IS 'Priority level: low, medium, high, urgent';
COMMENT ON COLUMN ai_expense_suggestions.confidence IS 'AI confidence score for this suggestion (0.00-1.00)';
COMMENT ON COLUMN ai_expense_suggestions.metadata IS 'Additional data specific to the suggestion type';
COMMENT ON COLUMN ai_expense_suggestions.is_dismissed IS 'Whether user dismissed this suggestion';
COMMENT ON COLUMN ai_expense_suggestions.expires_at IS 'When this suggestion expires (null = never)';

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_vehicle ON ai_expense_suggestions(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_type ON ai_expense_suggestions(suggestion_type);
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_active ON ai_expense_suggestions(vehicle_id, is_dismissed, expires_at)
    WHERE is_dismissed = FALSE AND (expires_at IS NULL OR expires_at > NOW());
CREATE INDEX IF NOT EXISTS idx_ai_suggestions_priority ON ai_expense_suggestions(priority, created_at DESC);

-- Create RLS policies
ALTER TABLE ai_expense_suggestions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own vehicle's suggestions
CREATE POLICY "Users can view their vehicle suggestions"
    ON ai_expense_suggestions
    FOR SELECT
    USING (
        vehicle_id IN (
            SELECT id FROM vehicles WHERE user_id = auth.uid()
        )
    );

-- Policy: Users can dismiss their own suggestions
CREATE POLICY "Users can dismiss their suggestions"
    ON ai_expense_suggestions
    FOR UPDATE
    USING (
        vehicle_id IN (
            SELECT id FROM vehicles WHERE user_id = auth.uid()
        )
    )
    WITH CHECK (
        vehicle_id IN (
            SELECT id FROM vehicles WHERE user_id = auth.uid()
        )
    );

-- Policy: Service role can insert suggestions
CREATE POLICY "Service role can insert suggestions"
    ON ai_expense_suggestions
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');
