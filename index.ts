// Video Upload Handler Edge Function
// This function processes video uploads, generates thumbnails, and creates different quality versions

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1';

interface VideoMetadata {
  showId: string;
  episodeId: string;
  title: string;
  description: string;
  seasonNumber: number;
  episodeNumber: number;
  isPremium: boolean;
  isTrailer: boolean;
}

interface VideoProcessingResult {
  success: boolean;
  videoUrl?: string;
  thumbnailUrl?: string;
  error?: string;
  qualities?: string[];
  duration?: number;
  fileSize?: number;
}

serve(async (req) => {
  try {
    // Get authorization header
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Verify admin user
    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Check if user is admin
    const { data: profile, error: profileError } = await supabase
      .from('user_profiles')
      .select('is_admin')
      .eq('id', user.id)
      .single();

    if (profileError || !profile || !profile.is_admin) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized: Admin access required' }),
        { status: 403, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Parse request body
    const { videoFile, metadata } = await req.json() as { 
      videoFile: string; // Base64 encoded or URL
      metadata: VideoMetadata;
    };

    if (!videoFile || !metadata) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Process video (in a real implementation, this would be more complex)
    const result = await processVideo(supabase, videoFile, metadata);

    if (!result.success) {
      return new Response(
        JSON.stringify({ error: result.error }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Update episode record with video information
    const { error: updateError } = await supabase
      .from('episodes')
      .update({
        video_url: result.videoUrl,
        thumbnail_url: result.thumbnailUrl,
        video_duration: result.duration,
        file_size: result.fileSize,
        status: 'published',
        updated_at: new Date().toISOString()
      })
      .eq('id', metadata.episodeId);

    if (updateError) {
      return new Response(
        JSON.stringify({ error: 'Failed to update episode record', details: updateError }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // Return success response
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Video processed successfully',
        videoUrl: result.videoUrl,
        thumbnailUrl: result.thumbnailUrl,
        qualities: result.qualities
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Error processing video upload:', error);
    return new Response(
      JSON.stringify({ error: 'Internal server error', details: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
});

// Function to process video (simplified for this example)
async function processVideo(
  supabase: any,
  videoFile: string,
  metadata: VideoMetadata
): Promise<VideoProcessingResult> {
  try {
    // In a real implementation, this would:
    // 1. Download the video if it's a URL
    // 2. Generate multiple quality versions (1080p, 720p, 480p, etc.)
    // 3. Create HLS/DASH manifest for adaptive streaming
    // 4. Extract thumbnail from video
    // 5. Upload all files to storage
    // 6. Return URLs and metadata

    // For this example, we'll simulate the process
    
    // Generate unique file names
    const timestamp = Date.now();
    const videoFileName = `${metadata.showId}/${metadata.seasonNumber}/${metadata.episodeNumber}/${timestamp}/master.m3u8`;
    const thumbnailFileName = `${metadata.showId}/${metadata.seasonNumber}/${metadata.episodeNumber}/${timestamp}/thumbnail.jpg`;
    
    // Simulate video processing time
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Simulate video qualities
    const qualities = ['1080p', '720p', '480p', '360p'];
    
    // Simulate video duration and file size
    const duration = Math.floor(Math.random() * 1800) + 1200; // 20-50 minutes
    const fileSize = Math.floor(Math.random() * 500000000) + 100000000; // 100MB-600MB
    
    // In a real implementation, we would upload the processed files to storage
    // For this example, we'll just return the paths
    
    const videoUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/videos/${videoFileName}`;
    const thumbnailUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/thumbnails/${thumbnailFileName}`;
    
    return {
      success: true,
      videoUrl,
      thumbnailUrl,
      qualities,
      duration,
      fileSize
    };
    
  } catch (error) {
    console.error('Error in video processing:', error);
    return {
      success: false,
      error: `Video processing failed: ${error.message}`
    };
  }
}

