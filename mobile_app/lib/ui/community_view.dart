import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/custom_widgets.dart';

class CommunityView extends StatefulWidget {
  @override
  _CommunityViewState createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  final List<Map<String, dynamic>> _posts = [
    {
      'author': 'Rajesh Kumar',
      'avatar': '👨‍🌾',
      'content': 'My sugarcane crop recovered after using the app recommendations!',
      'likes': 45,
      'comments': 8,
      'timestamp': '2 hours ago',
      'liked': false,
    },
    {
      'author': 'Priya Singh',
      'avatar': '👩‍🌾',
      'content': 'The wheat pest detection is so accurate. Saved my entire field!',
      'likes': 62,
      'comments': 12,
      'timestamp': '4 hours ago',
      'liked': false,
    },
    {
      'author': 'Amit Patel',
      'avatar': '👨‍💼',
      'content': 'Just started using Anaj.ai. Very impressed with the interface!',
      'likes': 38,
      'comments': 5,
      'timestamp': '6 hours ago',
      'liked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Community"),
        subtitle: Text("समुदाय"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No new notifications")),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildPostInputCard();
          }
          return _buildPostCard(index - 1);
        },
      ),
    );
  }

  Widget _buildPostInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(Icons.person),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showPostDialog();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Share your experience...",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("Photo"),
                  onPressed: () {},
                ),
                TextButton.icon(
                  icon: Icon(Icons.tag),
                  label: Text("Tag"),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(int index) {
    final post = _posts[index];
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(post['avatar']),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['author'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          post['timestamp'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // Post Content
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              post['content'],
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          // Post Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.favorite_border),
                  label: Text(post['likes'].toString()),
                  onPressed: () {
                    setState(() {
                      _posts[index]['liked'] = !_posts[index]['liked'];
                    });
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined),
                  label: Text(post['comments'].toString()),
                  onPressed: () {},
                ),
                TextButton.icon(
                  icon: Icon(Icons.share),
                  label: Text("Share"),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Share Experience"),
        content: TextField(
          decoration: InputDecoration(
            hintText: "What's on your mind?",
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Post shared successfully!")),
              );
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }
}
