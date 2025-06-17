import 'package:flutter/material.dart';

class ContactDeveloperScreen extends StatefulWidget {
  const ContactDeveloperScreen({Key? key}) : super(key: key);

  @override
  State<ContactDeveloperScreen> createState() => _ContactDeveloperScreenState();
}

class _ContactDeveloperScreenState extends State<ContactDeveloperScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCategory;
  bool _agree = false;

  final List<String> _categories = [
    'Technical Issue',
    'Account',
    'Feedback',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F26),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Contact Developer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildInputField('Your Name:', _nameController),
                    const SizedBox(height: 20),
                    _buildInputField('Your Email:', _emailController),
                    const SizedBox(height: 20),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 20),
                    _buildInputField('Title:', _titleController),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 24),
                    _buildAgreementCheckbox(),
                    const SizedBox(height: 12),
                    _buildPrivacyPolicyText(),
                    const SizedBox(height: 40),
                    _buildDisclaimerText(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8E96),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF3A4047),
                width: 1.0,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(bottom: 12, top: 8),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Category:',
              style: TextStyle(
                color: Color(0xFF8A8E96),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text(
                    'Select Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 24,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  dropdownColor: const Color(0xFF2A2F36),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: const Color(0xFF3A4047),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF3A4047),
            width: 1.0,
          ),
        ),
      ),
      child: TextField(
        controller: _descController,
        maxLines: 6,
        minLines: 4,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: const InputDecoration(
          hintText: 'Describe your problem in detail here',
          hintStyle: TextStyle(
            color: Color(0xFF5A5E66),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 8, bottom: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildAgreementCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _agree,
              onChanged: (bool? value) {
                setState(() {
                  _agree = value ?? false;
                });
              },
              activeColor: Colors.transparent,
              checkColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFF5A5E66),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'I agree to the processing of my personal data by MetaQuotes Ltd for request handling purposes.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyPolicyText() {
    return Row(
      children: [
        const Text(
          'Please have a look at our ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Open privacy policy link
          },
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Color(0xFF4A9EFF),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerText() {
    return Text(
      'MetaQuotes Ltd is a software development company and does not provide any financial, investment, brokerage or trading services.',
      style: const TextStyle(
        color: Color(0xFF5A5E66),
        fontSize: 12,
        height: 1.4,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _agree &&
                _nameController.text.isNotEmpty &&
                _emailController.text.isNotEmpty &&
                _titleController.text.isNotEmpty &&
                _descController.text.isNotEmpty &&
                _selectedCategory != null
            ? () {
                // TODO: Implement send functionality
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _agree &&
                  _nameController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty &&
                  _titleController.text.isNotEmpty &&
                  _descController.text.isNotEmpty &&
                  _selectedCategory != null
              ? const Color(0xFF4A9EFF)
              : const Color(0xFF3A4047),
          foregroundColor: _agree &&
                  _nameController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty &&
                  _titleController.text.isNotEmpty &&
                  _descController.text.isNotEmpty &&
                  _selectedCategory != null
              ? Colors.white
              : const Color(0xFF6A6E76),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'SEND',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
