-- Row Level Security (RLS) Policies for Indian TV Streaming App
-- These policies ensure users can only access data they're authorized to see

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE watch_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_analytics ENABLE ROW LEVEL SECURITY;

-- Categories policies (public read access)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Categories are viewable by everyone" ON categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Only admins can manage categories" ON categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Shows policies
ALTER TABLE shows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published shows are viewable by everyone" ON shows
    FOR SELECT USING (status = 'published');

CREATE POLICY "Only admins can manage shows" ON shows
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Episodes policies
ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published episodes are viewable by everyone" ON episodes
    FOR SELECT USING (
        status = 'published' AND
        EXISTS (SELECT 1 FROM shows WHERE id = episodes.show_id AND status = 'published')
    );

CREATE POLICY "Premium episodes require premium access" ON episodes
    FOR SELECT USING (
        status = 'published' AND
        EXISTS (SELECT 1 FROM shows WHERE id = episodes.show_id AND status = 'published') AND
        (
            is_premium = false OR 
            is_trailer = true OR
            has_premium_access(auth.uid())
        )
    );

CREATE POLICY "Only admins can manage episodes" ON episodes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- User profiles policies
CREATE POLICY "Users can view their own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON user_profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can update user profiles" ON user_profiles
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- User watchlist policies
CREATE POLICY "Users can manage their own watchlist" ON user_watchlist
    FOR ALL USING (auth.uid() = user_id);

-- User favorites policies
CREATE POLICY "Users can manage their own favorites" ON user_favorites
    FOR ALL USING (auth.uid() = user_id);

-- Watch history policies
CREATE POLICY "Users can manage their own watch history" ON watch_history
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all watch history" ON watch_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Downloads policies
CREATE POLICY "Users can manage their own downloads" ON downloads
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Premium users can download premium content" ON downloads
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        (
            NOT EXISTS (
                SELECT 1 FROM episodes 
                WHERE id = episode_id AND is_premium = true
            ) OR
            has_premium_access(auth.uid())
        )
    );

-- User ratings policies
CREATE POLICY "Users can manage their own ratings" ON user_ratings
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "All users can view ratings" ON user_ratings
    FOR SELECT USING (true);

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "System can create notifications" ON notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can manage all notifications" ON notifications
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Subscription transactions policies
CREATE POLICY "Users can view their own transactions" ON subscription_transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can create transactions" ON subscription_transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System can update transactions" ON subscription_transactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all transactions" ON subscription_transactions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Content analytics policies
CREATE POLICY "System can create analytics" ON content_analytics
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all analytics" ON content_analytics
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Storage policies for video files and images
INSERT INTO storage.buckets (id, name, public) VALUES 
    ('videos', 'videos', false),
    ('thumbnails', 'thumbnails', true),
    ('avatars', 'avatars', true);

-- Video storage policies
CREATE POLICY "Authenticated users can view videos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'videos' AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Only admins can upload videos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'videos' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Only admins can update videos" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'videos' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Only admins can delete videos" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'videos' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Thumbnail storage policies
CREATE POLICY "Anyone can view thumbnails" ON storage.objects
    FOR SELECT USING (bucket_id = 'thumbnails');

CREATE POLICY "Only admins can upload thumbnails" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'thumbnails' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Only admins can update thumbnails" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'thumbnails' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Only admins can delete thumbnails" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'thumbnails' AND
        EXISTS (
            SELECT 1 FROM user_profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- Avatar storage policies
CREATE POLICY "Anyone can view avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete their own avatar" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Function to check content access based on subscription
CREATE OR REPLACE FUNCTION can_access_content(episode_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    episode_premium BOOLEAN;
    episode_trailer BOOLEAN;
    user_has_premium BOOLEAN;
BEGIN
    -- Get episode premium status
    SELECT is_premium, is_trailer INTO episode_premium, episode_trailer
    FROM episodes WHERE id = episode_uuid;
    
    -- If it's a trailer or free content, allow access
    IF episode_trailer = true OR episode_premium = false THEN
        RETURN TRUE;
    END IF;
    
    -- Check if user has premium access
    SELECT has_premium_access(auth.uid()) INTO user_has_premium;
    
    RETURN user_has_premium;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's subscription status
CREATE OR REPLACE FUNCTION get_subscription_status(user_uuid UUID)
RETURNS TABLE (
    plan subscription_plan,
    is_trial_active BOOLEAN,
    is_premium_active BOOLEAN,
    trial_days_remaining INTEGER,
    subscription_days_remaining INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.subscription_plan,
        CASE 
            WHEN up.subscription_plan = 'trial' AND up.trial_end_date > NOW() THEN TRUE
            ELSE FALSE
        END as is_trial_active,
        CASE 
            WHEN up.subscription_plan = 'premium' AND (up.subscription_end_date IS NULL OR up.subscription_end_date > NOW()) THEN TRUE
            WHEN up.subscription_plan = 'trial' AND up.trial_end_date > NOW() THEN TRUE
            ELSE FALSE
        END as is_premium_active,
        CASE 
            WHEN up.subscription_plan = 'trial' AND up.trial_end_date > NOW() 
            THEN EXTRACT(DAY FROM up.trial_end_date - NOW())::INTEGER
            ELSE 0
        END as trial_days_remaining,
        CASE 
            WHEN up.subscription_plan = 'premium' AND up.subscription_end_date > NOW() 
            THEN EXTRACT(DAY FROM up.subscription_end_date - NOW())::INTEGER
            ELSE 0
        END as subscription_days_remaining
    FROM user_profiles up
    WHERE up.id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to activate free trial
CREATE OR REPLACE FUNCTION activate_free_trial(user_uuid UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_plan subscription_plan;
    has_used_trial BOOLEAN;
BEGIN
    -- Check current subscription plan
    SELECT subscription_plan INTO current_plan
    FROM user_profiles WHERE id = user_uuid;
    
    -- Check if user has already used trial
    SELECT EXISTS(
        SELECT 1 FROM user_profiles 
        WHERE id = user_uuid AND trial_start_date IS NOT NULL
    ) INTO has_used_trial;
    
    -- Only allow trial activation for free users who haven't used trial
    IF current_plan = 'free' AND NOT has_used_trial THEN
        UPDATE user_profiles 
        SET 
            subscription_plan = 'trial',
            trial_start_date = NOW(),
            trial_end_date = NOW() + INTERVAL '7 days',
            updated_at = NOW()
        WHERE id = user_uuid;
        
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to upgrade to premium
CREATE OR REPLACE FUNCTION upgrade_to_premium(user_uuid UUID, duration_months INTEGER DEFAULT 1)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE user_profiles 
    SET 
        subscription_plan = 'premium',
        subscription_start_date = NOW(),
        subscription_end_date = NOW() + (duration_months || ' months')::INTERVAL,
        updated_at = NOW()
    WHERE id = user_uuid;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

