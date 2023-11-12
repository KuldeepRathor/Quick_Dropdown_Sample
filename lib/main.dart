import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Dropdown',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quick Dropdown'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: QuickDropdown(
                items: List.generate(10, (index) => 'Item $index'),
                selectedValue: 'Select',
                onChanged: (String? value) {
                  debugPrint('Selected value: $value');
                },
                onSearch: (String searchQuery) {
                  debugPrint('Search query: $searchQuery');
                  return Future.value([]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class QuickDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final Future<void> Function(String searchQuery) onSearch;
  final TextStyle? textStyle;
  final IconData? dropdownIcon;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? dividerColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? searchIconColor;
  final Color? searchHintColor;
  final Color? errorTextColor;
  final double? fontSize;
  final double? itemHeight;

  const QuickDropdown({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.onSearch,
    this.textStyle,
    this.dropdownIcon,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.dividerColor,
    this.textColor,
    this.hintColor,
    this.searchIconColor,
    this.searchHintColor,
    this.errorTextColor,
    this.fontSize,
    this.itemHeight,
    Key? key,
  }) : super(key: key);

  @override
  _QuickDropdownState createState() => _QuickDropdownState();
}

class _QuickDropdownState extends State<QuickDropdown> {
  bool isDropdownOpen = false;
  String? selectedValue;
  String? errorText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool isdarkmode = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        color: widget.backgroundColor ?? Colors.transparent,
        border: Border.all(
          color: widget.borderColor ??
              (isdarkmode ? const Color(0xffA3A3A3) : const Color(0xffDCDCDC)),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isDropdownOpen = !isDropdownOpen;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.02,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedValue ?? "Select",
                      style: widget.textStyle ??
                          TextStyle(
                            fontSize: widget.fontSize ?? 16,
                            color: widget.textColor ??
                                (isdarkmode
                                    ? const Color(0xffA3A3A3)
                                    : const Color(0xffDCDCDC)),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    widget.dropdownIcon ??
                        (isDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                    color: widget.textColor ??
                        (isdarkmode
                            ? const Color(0xffA3A3A3)
                            : const Color(0xffDCDCDC)),
                  ),
                ],
              ),
            ),
          ),
          if (isDropdownOpen)
            Column(
              children: [
                TextField(
                  onChanged: ((value) {
                    setState(() {
                      selectedValue = value;
                    });
                    widget.onSearch(value);

                    setState(() {
                      errorText = null;
                    });

                    widget.onSearch(value).catchError((error) {
                      setState(() {
                        errorText = "Search failed: $error";
                      });
                    });
                  }),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(
                      fontSize: widget.fontSize ?? 16,
                      color: widget.searchHintColor ??
                          (isdarkmode
                              ? const Color(0xffA3A3A3)
                              : const Color(0xffDCDCDC)),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: widget.searchIconColor ??
                          (isdarkmode
                              ? const Color(0xffA3A3A3)
                              : const Color(0xffDCDCDC)),
                    ),
                    border: InputBorder.none,
                  ),
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorText!,
                      style:
                          TextStyle(color: widget.errorTextColor ?? Colors.red),
                    ),
                  ),
                if (!isLoading && widget.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No items found.'),
                  ),
                if (!isLoading && widget.items.isNotEmpty)
                  SizedBox(
                    height: widget.itemHeight ?? 150,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                        height: 2,
                        thickness: 1.5,
                        color: widget.dividerColor ??
                            (isdarkmode
                                ? const Color(0xffA3A3A3)
                                : const Color(0xffDCDCDC)),
                      ),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedValue = item;
                              isDropdownOpen = false;
                              widget.onChanged(item);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.02,
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: widget.fontSize ?? 16,
                                color: widget.textColor ??
                                    (isdarkmode
                                        ? const Color(0xffA3A3A3)
                                        : const Color(0xffDCDCDC)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
